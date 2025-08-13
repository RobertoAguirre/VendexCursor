import Anthropic from '@anthropic-ai/sdk';
import { ClaudeRequest, Product } from '../types';

export class ClaudeService {
  static async generateResponse(request: ClaudeRequest): Promise<string> {
    const { business_id, customer_message, conversation_context, products } = request;

    // Obtener información del negocio incluyendo su API key
    const business = await this.getBusinessInfo(business_id);
    
    if (!business.anthropic_api_key) {
      return 'Disculpa, el asistente no está configurado correctamente. Contacta al administrador.';
    }

    // Crear instancia de Anthropic con la API key del negocio específico
    const anthropic = new Anthropic({
      apiKey: business.anthropic_api_key,
    });
    
    // Construir prompt personalizado
    const prompt = this.buildPrompt(business, products, customer_message, conversation_context);

    try {
      const response = await anthropic.messages.create({
        model: 'claude-3-sonnet-20240229',
        max_tokens: 1000,
        temperature: 0.7,
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ]
      });

      return response.content[0].type === 'text' ? response.content[0].text : '';
    } catch (error) {
      console.error('Error con Claude para negocio', business_id, ':', error);
      return 'Disculpa, estoy teniendo problemas técnicos. ¿Podrías intentar de nuevo?';
    }
  }

  private static async getBusinessInfo(businessId: number): Promise<any> {
    const { Pool } = require('pg');
    const pool = new Pool({ connectionString: process.env.DATABASE_URL });
    
    const result = await pool.query(
      `SELECT 
        name, 
        business_type, 
        description, 
        assistant_personality,
        anthropic_api_key,
        stripe_secret_key,
        ultramsg_instance_id,
        ultramsg_token
       FROM businesses WHERE id = $1`,
      [businessId]
    );
    await pool.end();
    
    return result.rows[0];
  }

  private static buildPrompt(business: any, products: Product[], customerMessage: string, context: any): string {
    const productList = products.map(p => 
      `- ${p.name}: $${p.price} (Stock: ${p.stock}) - ${p.description || 'Sin descripción'}`
    ).join('\n');

    const personality = business.assistant_personality || 
      `Eres un asistente de ventas proactivo y amigable para ${business.name}, un ${business.business_type || 'negocio'}. 
       Tu objetivo es ayudar a vender productos de manera efectiva, siendo proactivo pero no agresivo.`;

    return `
${personality}

INFORMACIÓN DEL NEGOCIO:
- Nombre: ${business.name}
- Tipo: ${business.business_type || 'No especificado'}
- Descripción: ${business.description || 'No especificada'}

PRODUCTOS DISPONIBLES:
${productList}

CONTEXTO DE LA CONVERSACIÓN:
${JSON.stringify(context, null, 2)}

MENSAJE DEL CLIENTE:
"${customerMessage}"

INSTRUCCIONES:
1. Responde de manera natural y conversacional
2. Sé proactivo en recomendar productos relevantes
3. Si el cliente muestra interés en comprar, genera un link de pago
4. Mantén un tono amigable y profesional
5. No inventes productos que no estén en la lista
6. Si no hay stock, sugiere alternativas o informa sobre reposición

Responde al cliente:
`;
  }

  static async generatePaymentLink(businessId: number, products: Product[], customerPhone: string): Promise<string> {
    // Obtener credenciales de Stripe del negocio específico
    const business = await this.getBusinessInfo(businessId);
    
    if (!business.stripe_secret_key) {
      throw new Error('Stripe no configurado para este negocio');
    }

    // Aquí se integraría con Stripe usando las credenciales del negocio
    // Por ahora retornamos un placeholder
    const total = products.reduce((sum, p) => sum + p.price, 0);
    return `https://checkout.stripe.com/pay/cs_test_placeholder#fid=${customerPhone}&amount=${total}`;
  }
} 