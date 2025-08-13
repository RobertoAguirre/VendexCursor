import { Router, Request, Response } from 'express';
import Stripe from 'stripe';
import pool from '../config/database';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Crear link de pago
router.post('/create-payment-link', authenticateToken, async (req: any, res: Response) => {
  try {
    const { products, customer_phone, success_url, cancel_url } = req.body;
    const business = req.business;

    if (!business.stripe_secret_key) {
      return res.status(400).json({ error: 'Stripe no configurado para este negocio' });
    }

    if (!products || !Array.isArray(products) || products.length === 0) {
      return res.status(400).json({ error: 'Productos requeridos' });
    }

    // Verificar productos y calcular total
    const client = await pool.connect();
    let total = 0;
    const verifiedProducts = [];

    for (const product of products) {
      const result = await client.query(
        'SELECT * FROM products WHERE id = $1 AND business_id = $2 AND active = true AND stock > 0',
        [product.id, business.id]
      );

      if (result.rows.length === 0) {
        client.release();
        return res.status(400).json({ error: `Producto ${product.id} no encontrado o sin stock` });
      }

      const dbProduct = result.rows[0];
      total += dbProduct.price * (product.quantity || 1);
      verifiedProducts.push({
        ...dbProduct,
        quantity: product.quantity || 1
      });
    }

    client.release();

    // Crear Stripe instance
    const stripe = new Stripe(business.stripe_secret_key, {
      apiVersion: '2023-10-16'
    });

    // Crear line items para Stripe
    const lineItems = verifiedProducts.map(product => ({
      price_data: {
        currency: 'usd',
        product_data: {
          name: product.name,
          description: product.description
        },
        unit_amount: Math.round(product.price * 100) // Stripe usa centavos
      },
      quantity: product.quantity
    }));

    // Crear sesión de checkout
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: lineItems,
      mode: 'payment',
      success_url: success_url || `${process.env.FRONTEND_URL}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancel_url || `${process.env.FRONTEND_URL}/payment/cancel`,
      metadata: {
        business_id: business.id.toString(),
        customer_phone: customer_phone,
        products: JSON.stringify(verifiedProducts.map(p => ({ id: p.id, quantity: p.quantity })))
      }
    });

    // Guardar venta en la base de datos
    const dbClient = await pool.connect();
    await dbClient.query(
      `INSERT INTO sales (business_id, customer_phone, amount, stripe_payment_id, products, status)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [business.id, customer_phone, total, session.id, JSON.stringify(verifiedProducts), 'pending']
    );
    dbClient.release();

    res.json({
      payment_url: session.url,
      session_id: session.id,
      amount: total
    });

  } catch (error) {
    console.error('Error creando link de pago:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Webhook de Stripe
router.post('/webhook', async (req: Request, res: Response) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    // Buscar el negocio por el webhook secret
    const client = await pool.connect();
    const businessResult = await client.query(
      'SELECT * FROM businesses WHERE stripe_webhook_secret = $1',
      [req.headers['stripe-signature']]
    );
    client.release();

    if (businessResult.rows.length === 0) {
      return res.status(400).json({ error: 'Negocio no encontrado' });
    }

    const business = businessResult.rows[0];
    const stripe = new Stripe(business.stripe_secret_key, {
      apiVersion: '2023-10-16'
    });

    event = stripe.webhooks.constructEvent(req.body, sig as string, business.stripe_webhook_secret);
  } catch (err) {
    console.error('Error verificando webhook:', err);
    return res.status(400).json({ error: 'Webhook error' });
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handlePaymentSuccess(event.data.object);
        break;
      case 'checkout.session.expired':
        await handlePaymentExpired(event.data.object);
        break;
      default:
        console.log(`Evento no manejado: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Error procesando webhook:', error);
    res.status(500).json({ error: 'Error procesando webhook' });
  }
});

// Manejar pago exitoso
async function handlePaymentSuccess(session: any) {
  const client = await pool.connect();
  
  try {
    // Actualizar venta
    await client.query(
      'UPDATE sales SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE stripe_payment_id = $2',
      ['completed', session.id]
    );

    // Actualizar stock de productos
    const products = JSON.parse(session.metadata.products);
    for (const product of products) {
      await client.query(
        'UPDATE products SET stock = stock - $1 WHERE id = $2',
        [product.quantity, product.id]
      );
    }

    console.log(`Pago completado para sesión: ${session.id}`);
  } catch (error) {
    console.error('Error procesando pago exitoso:', error);
  } finally {
    client.release();
  }
}

// Manejar pago expirado
async function handlePaymentExpired(session: any) {
  const client = await pool.connect();
  
  try {
    await client.query(
      'UPDATE sales SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE stripe_payment_id = $2',
      ['cancelled', session.id]
    );

    console.log(`Pago expirado para sesión: ${session.id}`);
  } catch (error) {
    console.error('Error procesando pago expirado:', error);
  } finally {
    client.release();
  }
}

// Obtener ventas del negocio
router.get('/sales', authenticateToken, async (req: any, res: Response) => {
  try {
    const businessId = req.business.id;
    const { status, limit = 20, offset = 0 } = req.query;

    let query = 'SELECT * FROM sales WHERE business_id = $1';
    const params = [businessId];
    let paramIndex = 2;

    if (status) {
      query += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const client = await pool.connect();
    const result = await client.query(query, params);
    client.release();

    res.json({ sales: result.rows });

  } catch (error) {
    console.error('Error obteniendo ventas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Obtener estadísticas de ventas
router.get('/sales/stats', authenticateToken, async (req: any, res: Response) => {
  try {
    const businessId = req.business.id;

    const client = await pool.connect();
    
    // Total de ventas
    const totalSales = await client.query(
      'SELECT COUNT(*) as total FROM sales WHERE business_id = $1',
      [businessId]
    );

    // Ventas completadas
    const completedSales = await client.query(
      'SELECT COUNT(*) as completed, COALESCE(SUM(amount), 0) as revenue FROM sales WHERE business_id = $1 AND status = $2',
      [businessId, 'completed']
    );

    // Ventas de hoy
    const todaySales = await client.query(
      'SELECT COUNT(*) as today, COALESCE(SUM(amount), 0) as today_revenue FROM sales WHERE business_id = $1 AND DATE(created_at) = CURRENT_DATE',
      [businessId]
    );

    // Ventas del mes
    const monthSales = await client.query(
      'SELECT COUNT(*) as month, COALESCE(SUM(amount), 0) as month_revenue FROM sales WHERE business_id = $1 AND DATE_TRUNC(\'month\', created_at) = DATE_TRUNC(\'month\', CURRENT_DATE)',
      [businessId]
    );

    client.release();

    res.json({
      stats: {
        total: parseInt(totalSales.rows[0].total),
        completed: parseInt(completedSales.rows[0].completed),
        revenue: parseFloat(completedSales.rows[0].revenue),
        today: parseInt(todaySales.rows[0].today),
        today_revenue: parseFloat(todaySales.rows[0].today_revenue),
        month: parseInt(monthSales.rows[0].month),
        month_revenue: parseFloat(monthSales.rows[0].month_revenue)
      }
    });

  } catch (error) {
    console.error('Error obteniendo estadísticas de ventas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

export default router; 