import axios from 'axios';
import { Pool } from 'pg';

export class UltraMsgService {
  static async sendMessage(businessId: number, to: string, message: string, messageType: string = 'text'): Promise<boolean> {
    try {
      // Obtener credenciales del negocio
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.ultramsg_instance_id || !business.ultramsg_token) {
        throw new Error('UltraMsg no configurado para este negocio');
      }

      const url = `https://api.ultramsg.com/${business.ultramsg_instance_id}/messages/chat`;
      
      const payload = {
        to: to,
        body: message,
        type: messageType
      };

      const response = await axios.post(url, payload, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${business.ultramsg_token}`
        }
      });

      if (response.status === 200) {
        console.log(`Mensaje enviado exitosamente a ${to} para negocio ${businessId}`);
        return true;
      }

      return false;
    } catch (error) {
      console.error('Error enviando mensaje UltraMsg para negocio', businessId, ':', error);
      return false;
    }
  }

  static async sendImage(businessId: number, to: string, imageUrl: string, caption?: string): Promise<boolean> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.ultramsg_instance_id || !business.ultramsg_token) {
        throw new Error('UltraMsg no configurado para este negocio');
      }

      const url = `https://api.ultramsg.com/${business.ultramsg_instance_id}/messages/image`;
      
      const payload = {
        to: to,
        image: imageUrl,
        caption: caption || ''
      };

      const response = await axios.post(url, payload, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${business.ultramsg_token}`
        }
      });

      return response.status === 200;
    } catch (error) {
      console.error('Error enviando imagen UltraMsg para negocio', businessId, ':', error);
      return false;
    }
  }

  static async sendPaymentLink(businessId: number, to: string, paymentUrl: string, amount: number, description: string): Promise<boolean> {
    try {
      const message = `💳 *Link de Pago*\n\n💰 Total: $${amount}\n📝 ${description}\n\n🔗 [Pagar Ahora](${paymentUrl})\n\n¡Gracias por tu compra! 🛒`;
      
      return await this.sendMessage(businessId, to, message);
    } catch (error) {
      console.error('Error enviando link de pago UltraMsg para negocio', businessId, ':', error);
      return false;
    }
  }

  private static async getBusinessCredentials(businessId: number): Promise<any> {
    const pool = new Pool({ connectionString: process.env.DATABASE_URL });
    
    const result = await pool.query(
      'SELECT ultramsg_instance_id, ultramsg_token, whatsapp_number FROM businesses WHERE id = $1',
      [businessId]
    );
    await pool.end();
    
    return result.rows[0];
  }

  static async verifyConnection(businessId: number): Promise<boolean> {
    try {
      const business = await this.getBusinessCredentials(businessId);
      
      if (!business.ultramsg_instance_id || !business.ultramsg_token) {
        return false;
      }

      const url = `https://api.ultramsg.com/${business.ultramsg_instance_id}/instance/connectionState`;
      
      const response = await axios.get(url, {
        headers: {
          'Authorization': `Bearer ${business.ultramsg_token}`
        }
      });

      return response.status === 200 && response.data.state === 'open';
    } catch (error) {
      console.error('Error verificando conexión UltraMsg para negocio', businessId, ':', error);
      return false;
    }
  }
}
