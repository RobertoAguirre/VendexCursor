import { Router, Request, Response } from 'express';
import Joi from 'joi';
import pool from '../config/database';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Validación de esquemas
const updateBusinessSchema = Joi.object({
  name: Joi.string().optional().min(2).max(255),
  phone: Joi.string().optional(),
  business_type: Joi.string().optional(),
  description: Joi.string().optional(),
  whatsapp_number: Joi.string().optional(),
  assistant_personality: Joi.string().optional(),
  stripe_secret_key: Joi.string().optional(),
  stripe_webhook_secret: Joi.string().optional()
});

// Obtener información del negocio
router.get('/', authenticateToken, async (req: any, res: Response) => {
  try {
    const business = req.business;
    
    // Obtener estadísticas básicas
    const client = await pool.connect();
    
    const productsCount = await client.query(
      'SELECT COUNT(*) as count FROM products WHERE business_id = $1',
      [business.id]
    );
    
    const conversationsCount = await client.query(
      'SELECT COUNT(*) as count FROM conversations WHERE business_id = $1',
      [business.id]
    );
    
    const salesCount = await client.query(
      'SELECT COUNT(*) as count, COALESCE(SUM(amount), 0) as total FROM sales WHERE business_id = $1 AND status = $2',
      [business.id, 'completed']
    );
    
    client.release();

    res.json({
      business: {
        id: business.id,
        name: business.name,
        email: business.email,
        phone: business.phone,
        business_type: business.business_type,
        description: business.description,
        whatsapp_number: business.whatsapp_number,
        assistant_personality: business.assistant_personality,
        created_at: business.created_at
      },
      stats: {
        products: parseInt(productsCount.rows[0].count),
        conversations: parseInt(conversationsCount.rows[0].count),
        sales: parseInt(salesCount.rows[0].count),
        total_revenue: parseFloat(salesCount.rows[0].total)
      }
    });

  } catch (error) {
    console.error('Error obteniendo información del negocio:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Actualizar información del negocio
router.put('/', authenticateToken, async (req: any, res: Response) => {
  try {
    const { error, value } = updateBusinessSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const businessId = req.business.id;
    const updateFields = Object.keys(value).map((key, index) => `${key} = $${index + 2}`).join(', ');
    const values = [businessId, ...Object.values(value)];

    const client = await pool.connect();
    const result = await client.query(
      `UPDATE businesses 
       SET ${updateFields}, updated_at = CURRENT_TIMESTAMP 
       WHERE id = $1 
       RETURNING id, name, email, phone, business_type, description, whatsapp_number, assistant_personality, created_at, updated_at`,
      values
    );
    
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Negocio no encontrado' });
    }

    res.json({
      message: 'Negocio actualizado exitosamente',
      business: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando negocio:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Configurar personalidad del asistente
router.post('/assistant-personality', authenticateToken, async (req: any, res: Response) => {
  try {
    const { personality } = req.body;
    
    if (!personality || typeof personality !== 'string') {
      return res.status(400).json({ error: 'Personalidad del asistente requerida' });
    }

    const client = await pool.connect();
    await client.query(
      'UPDATE businesses SET assistant_personality = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      [personality, req.business.id]
    );
    client.release();

    res.json({
      message: 'Personalidad del asistente configurada exitosamente',
      personality
    });

  } catch (error) {
    console.error('Error configurando personalidad:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Configurar WhatsApp
router.post('/whatsapp', authenticateToken, async (req: any, res: Response) => {
  try {
    const { whatsapp_number } = req.body;
    
    if (!whatsapp_number) {
      return res.status(400).json({ error: 'Número de WhatsApp requerido' });
    }

    const client = await pool.connect();
    await client.query(
      'UPDATE businesses SET whatsapp_number = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      [whatsapp_number, req.business.id]
    );
    client.release();

    res.json({
      message: 'WhatsApp configurado exitosamente',
      whatsapp_number
    });

  } catch (error) {
    console.error('Error configurando WhatsApp:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Configurar Stripe
router.post('/stripe', authenticateToken, async (req: any, res: Response) => {
  try {
    const { stripe_secret_key, stripe_webhook_secret } = req.body;
    
    if (!stripe_secret_key) {
      return res.status(400).json({ error: 'Clave secreta de Stripe requerida' });
    }

    const client = await pool.connect();
    await client.query(
      'UPDATE businesses SET stripe_secret_key = $1, stripe_webhook_secret = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3',
      [stripe_secret_key, stripe_webhook_secret, req.business.id]
    );
    client.release();

    res.json({
      message: 'Stripe configurado exitosamente'
    });

  } catch (error) {
    console.error('Error configurando Stripe:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

export default router; 