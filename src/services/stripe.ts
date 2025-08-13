import Stripe from 'stripe';
import { Pool } from 'pg';
import { Product } from '../types';

export class StripeService {
  static async createPaymentLink(businessId: number, products: Product[], customerPhone: string, customerName?: string): Promise<string> {
    try {
      // Obtener credenciales del negocio
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.stripe_secret_key) {
        throw new Error('Stripe no configurado para este negocio');
      }

      // Crear instancia de Stripe con las credenciales del negocio
      const stripe = new Stripe(business.stripe_secret_key, {
        apiVersion: '2023-10-16',
      });

      // Calcular total
      const total = products.reduce((sum, product) => sum + product.price, 0);
      
      // Crear línea de items para Stripe
      const lineItems = products.map(product => ({
        price_data: {
          currency: 'usd',
          product_data: {
            name: product.name,
            description: product.description || '',
          },
          unit_amount: Math.round(product.price * 100), // Stripe usa centavos
        },
        quantity: 1,
      }));

      // Crear sesión de checkout
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: lineItems,
        mode: 'payment',
        success_url: `${process.env.FRONTEND_URL}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${process.env.FRONTEND_URL}/payment/cancel`,
        customer_email: customerName ? `${customerPhone}@whatsapp.com` : undefined,
        metadata: {
          business_id: businessId.toString(),
          customer_phone: customerPhone,
          customer_name: customerName || '',
          products: JSON.stringify(products.map(p => ({ id: p.id, name: p.name, price: p.price })))
        }
      });

      return session.url || '';
    } catch (error) {
      console.error('Error creando link de pago Stripe para negocio', businessId, ':', error);
      throw error;
    }
  }

  static async createProduct(businessId: number, product: Product): Promise<string> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.stripe_secret_key) {
        throw new Error('Stripe no configurado para este negocio');
      }

      const stripe = new Stripe(business.stripe_secret_key, {
        apiVersion: '2023-10-16',
      });

      const stripeProduct = await stripe.products.create({
        name: product.name,
        description: product.description || '',
        metadata: {
          business_id: businessId.toString(),
          product_id: product.id.toString()
        }
      });

      return stripeProduct.id;
    } catch (error) {
      console.error('Error creando producto Stripe para negocio', businessId, ':', error);
      throw error;
    }
  }

  static async updateProduct(businessId: number, product: Product, stripeProductId: string): Promise<void> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.stripe_secret_key) {
        throw new Error('Stripe no configurado para este negocio');
      }

      const stripe = new Stripe(business.stripe_secret_key, {
        apiVersion: '2023-10-16',
      });

      await stripe.products.update(stripeProductId, {
        name: product.name,
        description: product.description || '',
      });
    } catch (error) {
      console.error('Error actualizando producto Stripe para negocio', businessId, ':', error);
      throw error;
    }
  }

  static async verifyWebhook(businessId: number, payload: string, signature: string): Promise<Stripe.Event> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.stripe_webhook_secret) {
        throw new Error('Webhook secret no configurado para este negocio');
      }

      const stripe = new Stripe(business.stripe_secret_key, {
        apiVersion: '2023-10-16',
      });

      return stripe.webhooks.constructEvent(payload, signature, business.stripe_webhook_secret);
    } catch (error) {
      console.error('Error verificando webhook Stripe para negocio', businessId, ':', error);
      throw error;
    }
  }

  static async getPaymentIntent(businessId: number, paymentIntentId: string): Promise<Stripe.PaymentIntent> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.stripe_secret_key) {
        throw new Error('Stripe no configurado para este negocio');
      }

      const stripe = new Stripe(business.stripe_secret_key, {
        apiVersion: '2023-10-16',
      });

      return await stripe.paymentIntents.retrieve(paymentIntentId);
    } catch (error) {
      console.error('Error obteniendo payment intent Stripe para negocio', businessId, ':', error);
      throw error;
    }
  }

  static async refundPayment(businessId: number, paymentIntentId: string, amount?: number): Promise<Stripe.Refund> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.stripe_secret_key) {
        throw new Error('Stripe no configurado para este negocio');
      }

      const stripe = new Stripe(business.stripe_secret_key, {
        apiVersion: '2023-10-16',
      });

      const refundData: any = {
        payment_intent: paymentIntentId,
      };

      if (amount) {
        refundData.amount = Math.round(amount * 100);
      }

      return await stripe.refunds.create(refundData);
    } catch (error) {
      console.error('Error procesando reembolso Stripe para negocio', businessId, ':', error);
      throw error;
    }
  }

  private static async getBusinessCredentials(businessId: number): Promise<any> {
    const pool = new Pool({ connectionString: process.env.DATABASE_URL });
    
    const result = await pool.query(
      'SELECT stripe_secret_key, stripe_webhook_secret, stripe_publishable_key FROM businesses WHERE id = $1',
      [businessId]
    );
    await pool.end();
    
    return result.rows[0];
  }

  static async verifyConnection(businessId: number): Promise<boolean> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.stripe_secret_key) {
        return false;
      }

      const stripe = new Stripe(business.stripe_secret_key, {
        apiVersion: '2023-10-16',
      });

      // Intentar obtener la cuenta para verificar credenciales
      await stripe.accounts.retrieve();
      return true;
    } catch (error) {
      console.error('Error verificando conexión Stripe para negocio', businessId, ':', error);
      return false;
    }
  }
}
