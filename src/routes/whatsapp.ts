import { Router, Request, Response } from 'express';
import axios from 'axios';
import pool from '../config/database';
import { ClaudeService } from '../services/claude';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Webhook para recibir mensajes de WhatsApp (UltraMsg)
router.post('/webhook', async (req: Request, res: Response) => {
  try {
    const { data } = req.body;
    
    if (!data || !data.key || !data.message) {
      return res.status(400).json({ error: 'Datos de mensaje inválidos' });
    }

    const { key, message } = data;
    const customerPhone = key.remoteJid?.replace('@s.whatsapp.net', '') || '';
    const messageContent = message.conversation || message.extendedTextMessage?.text || '';

    if (!customerPhone || !messageContent) {
      return res.status(400).json({ error: 'Datos de mensaje incompletos' });
    }

    // Buscar el negocio por el número de WhatsApp
    const client = await pool.connect();
    const businessResult = await client.query(
      'SELECT * FROM businesses WHERE whatsapp_number = $1',
      [key.participant?.replace('@s.whatsapp.net', '') || '']
    );

    if (businessResult.rows.length === 0) {
      client.release();
      return res.status(404).json({ error: 'Negocio no encontrado' });
    }

    const business = businessResult.rows[0];

    // Buscar o crear conversación
    let conversation = await client.query(
      'SELECT * FROM conversations WHERE business_id = $1 AND customer_phone = $2',
      [business.id, customerPhone]
    );

    if (conversation.rows.length === 0) {
      // Crear nueva conversación
      const newConversation = await client.query(
        `INSERT INTO conversations (business_id, customer_phone, status, context)
         VALUES ($1, $2, 'active', '{}')
         RETURNING *`,
        [business.id, customerPhone]
      );
      conversation = newConversation;
    }

    const conversationId = conversation.rows[0].id;

    // Guardar mensaje del cliente
    await client.query(
      `INSERT INTO messages (conversation_id, content, sender_type, message_type)
       VALUES ($1, $2, 'customer', 'text')`,
      [conversationId, messageContent]
    );

    // Obtener productos del negocio
    const productsResult = await client.query(
      'SELECT * FROM products WHERE business_id = $1 AND active = true AND stock > 0',
      [business.id]
    );

    const products = productsResult.rows;

    // Obtener contexto de la conversación
    const context = conversation.rows[0].context || {};

    // Generar respuesta con Claude
    const assistantResponse = await ClaudeService.generateResponse({
      business_id: business.id,
      customer_message: messageContent,
      conversation_context: context,
      products: products
    });

    // Guardar respuesta del asistente
    await client.query(
      `INSERT INTO messages (conversation_id, content, sender_type, message_type)
       VALUES ($1, $2, 'assistant', 'text')`,
      [conversationId, assistantResponse]
    );

    // Actualizar conversación
    await client.query(
      'UPDATE conversations SET last_message_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = $1',
      [conversationId]
    );

    client.release();

    // Enviar respuesta por WhatsApp
    await sendWhatsAppMessage(business.whatsapp_number, customerPhone, assistantResponse);

    res.json({ success: true, message: 'Mensaje procesado exitosamente' });

  } catch (error) {
    console.error('Error procesando mensaje de WhatsApp:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Enviar mensaje por WhatsApp
router.post('/send', authenticateToken, async (req: any, res: Response) => {
  try {
    const { customer_phone, message } = req.body;
    const business = req.business;

    if (!customer_phone || !message) {
      return res.status(400).json({ error: 'Teléfono y mensaje requeridos' });
    }

    if (!business.whatsapp_number) {
      return res.status(400).json({ error: 'WhatsApp no configurado para este negocio' });
    }

    const success = await sendWhatsAppMessage(business.whatsapp_number, customer_phone, message);

    if (success) {
      res.json({ message: 'Mensaje enviado exitosamente' });
    } else {
      res.status(500).json({ error: 'Error enviando mensaje' });
    }

  } catch (error) {
    console.error('Error enviando mensaje:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Función para enviar mensaje por WhatsApp usando UltraMsg
async function sendWhatsAppMessage(businessWhatsApp: string, customerPhone: string, message: string): Promise<boolean> {
  try {
    const response = await axios.post('https://api.ultramsg.com/instance_id/messages/chat', {
      token: process.env.ULTRAMSG_TOKEN,
      to: customerPhone,
      body: message
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    return response.status === 200;
  } catch (error) {
    console.error('Error enviando mensaje por WhatsApp:', error);
    return false;
  }
}

// Obtener conversaciones del negocio
router.get('/conversations', authenticateToken, async (req: any, res: Response) => {
  try {
    const businessId = req.business.id;
    const { status, limit = 20, offset = 0 } = req.query;

    let query = `
      SELECT c.*, 
             COUNT(m.id) as message_count,
             MAX(m.created_at) as last_message_time
      FROM conversations c
      LEFT JOIN messages m ON c.id = m.conversation_id
      WHERE c.business_id = $1
    `;
    
    const params = [businessId];
    let paramIndex = 2;

    if (status) {
      query += ` AND c.status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    query += ` GROUP BY c.id ORDER BY c.last_message_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const client = await pool.connect();
    const result = await client.query(query, params);
    client.release();

    res.json({ conversations: result.rows });

  } catch (error) {
    console.error('Error obteniendo conversaciones:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Obtener mensajes de una conversación
router.get('/conversations/:id/messages', authenticateToken, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const businessId = req.business.id;

    const client = await pool.connect();
    
    // Verificar que la conversación pertenece al negocio
    const conversationResult = await client.query(
      'SELECT id FROM conversations WHERE id = $1 AND business_id = $2',
      [id, businessId]
    );

    if (conversationResult.rows.length === 0) {
      client.release();
      return res.status(404).json({ error: 'Conversación no encontrada' });
    }

    // Obtener mensajes
    const messagesResult = await client.query(
      'SELECT * FROM messages WHERE conversation_id = $1 ORDER BY created_at ASC',
      [id]
    );

    client.release();

    res.json({ messages: messagesResult.rows });

  } catch (error) {
    console.error('Error obteniendo mensajes:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Marcar conversación como cerrada
router.patch('/conversations/:id/close', authenticateToken, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const businessId = req.business.id;

    const client = await pool.connect();
    const result = await client.query(
      'UPDATE conversations SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND business_id = $3 RETURNING *',
      ['closed', id, businessId]
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Conversación no encontrada' });
    }

    res.json({
      message: 'Conversación cerrada exitosamente',
      conversation: result.rows[0]
    });

  } catch (error) {
    console.error('Error cerrando conversación:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

export default router; 