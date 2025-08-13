import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import pool from '../config/database';

interface AuthRequest extends Request {
  business?: any;
}

export const authenticateToken = async (req: AuthRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token de acceso requerido' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    // Verificar que el negocio existe
    const client = await pool.connect();
    const result = await client.query('SELECT * FROM businesses WHERE id = $1', [decoded.businessId]);
    client.release();

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Negocio no encontrado' });
    }

    req.business = result.rows[0];
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Token inválido' });
  }
}; 