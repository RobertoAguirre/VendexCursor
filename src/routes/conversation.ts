import { Router, Request, Response } from 'express';
import pool from '../config/database';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Obtener todas las conversaciones del negocio
router.get('/', authenticateToken, async (req: any, res: Response) => {
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

// Obtener una conversación específica
router.get('/:id', authenticateToken, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const businessId = req.business.id;

    const client = await pool.connect();
    const result = await client.query(
      'SELECT * FROM conversations WHERE id = $1 AND business_id = $2',
      [id, businessId]
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Conversación no encontrada' });
    }

    res.json({ conversation: result.rows[0] });

  } catch (error) {
    console.error('Error obteniendo conversación:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Obtener mensajes de una conversación
router.get('/:id/messages', authenticateToken, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const businessId = req.business.id;
    const { limit = 50, offset = 0 } = req.query;

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
      'SELECT * FROM messages WHERE conversation_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
      [id, parseInt(limit), parseInt(offset)]
    );

    client.release();

    res.json({ 
      messages: messagesResult.rows.reverse(), // Ordenar por fecha ascendente
      total: messagesResult.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo mensajes:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Actualizar estado de conversación
router.patch('/:id/status', authenticateToken, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const businessId = req.business.id;

    if (!['active', 'closed', 'pending'].includes(status)) {
      return res.status(400).json({ error: 'Estado inválido' });
    }

    const client = await pool.connect();
    const result = await client.query(
      'UPDATE conversations SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND business_id = $3 RETURNING *',
      [status, id, businessId]
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Conversación no encontrada' });
    }

    res.json({
      message: 'Estado de conversación actualizado exitosamente',
      conversation: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando estado de conversación:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Obtener estadísticas de conversaciones
router.get('/stats/summary', authenticateToken, async (req: any, res: Response) => {
  try {
    const businessId = req.business.id;

    const client = await pool.connect();
    
    // Total de conversaciones
    const totalConversations = await client.query(
      'SELECT COUNT(*) as total FROM conversations WHERE business_id = $1',
      [businessId]
    );

    // Conversaciones activas
    const activeConversations = await client.query(
      'SELECT COUNT(*) as active FROM conversations WHERE business_id = $1 AND status = $2',
      [businessId, 'active']
    );

    // Conversaciones cerradas
    const closedConversations = await client.query(
      'SELECT COUNT(*) as closed FROM conversations WHERE business_id = $1 AND status = $2',
      [businessId, 'closed']
    );

    // Conversaciones de hoy
    const todayConversations = await client.query(
      'SELECT COUNT(*) as today FROM conversations WHERE business_id = $1 AND DATE(created_at) = CURRENT_DATE',
      [businessId]
    );

    // Promedio de mensajes por conversación
    const avgMessages = await client.query(
      `SELECT AVG(message_count) as avg_messages
       FROM (
         SELECT c.id, COUNT(m.id) as message_count
         FROM conversations c
         LEFT JOIN messages m ON c.id = m.conversation_id
         WHERE c.business_id = $1
         GROUP BY c.id
       ) as subquery`,
      [businessId]
    );

    client.release();

    res.json({
      stats: {
        total: parseInt(totalConversations.rows[0].total),
        active: parseInt(activeConversations.rows[0].active),
        closed: parseInt(closedConversations.rows[0].closed),
        today: parseInt(todayConversations.rows[0].today),
        avg_messages: parseFloat(avgMessages.rows[0].avg_messages) || 0
      }
    });

  } catch (error) {
    console.error('Error obteniendo estadísticas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Buscar conversaciones
router.get('/search', authenticateToken, async (req: any, res: Response) => {
  try {
    const businessId = req.business.id;
    const { q, status, limit = 20, offset = 0 } = req.query;

    let query = `
      SELECT DISTINCT c.*, 
             COUNT(m.id) as message_count,
             MAX(m.created_at) as last_message_time
      FROM conversations c
      LEFT JOIN messages m ON c.id = m.conversation_id
      WHERE c.business_id = $1
    `;
    
    const params = [businessId];
    let paramIndex = 2;

    if (q) {
      query += ` AND (c.customer_phone ILIKE $${paramIndex} OR EXISTS (
        SELECT 1 FROM messages msg 
        WHERE msg.conversation_id = c.id 
        AND msg.content ILIKE $${paramIndex}
      ))`;
      params.push(`%${q}%`);
      paramIndex++;
    }

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
    console.error('Error buscando conversaciones:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

export default router; 