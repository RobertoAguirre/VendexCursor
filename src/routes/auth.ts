import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import Joi from 'joi';
import pool from '../config/database';
import { CreateBusinessRequest, LoginRequest } from '../types';

const router = Router();

// Validación de esquemas
const registerSchema = Joi.object({
  name: Joi.string().required().min(2).max(255),
  email: Joi.string().email().required(),
  password: Joi.string().required().min(6),
  phone: Joi.string().optional(),
  business_type: Joi.string().optional(),
  description: Joi.string().optional()
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

// Registro de negocio
router.post('/register', async (req: Request, res: Response) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { name, email, password, phone, business_type, description }: CreateBusinessRequest = value;

    // Verificar si el email ya existe
    const client = await pool.connect();
    const existingBusiness = await client.query(
      'SELECT id FROM businesses WHERE email = $1',
      [email]
    );

    if (existingBusiness.rows.length > 0) {
      client.release();
      return res.status(400).json({ error: 'El email ya está registrado' });
    }

    // Hash de la contraseña
    const passwordHash = await bcrypt.hash(password, 12);

    // Crear el negocio
    const result = await client.query(
      `INSERT INTO businesses (name, email, password_hash, phone, business_type, description)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, name, email, phone, business_type, description, created_at`,
      [name, email, passwordHash, phone, business_type, description]
    );

    client.release();

    const business = result.rows[0];

    // Generar token JWT
    const token = jwt.sign(
      { businessId: business.id, email: business.email },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'Negocio registrado exitosamente',
      business: {
        id: business.id,
        name: business.name,
        email: business.email,
        phone: business.phone,
        business_type: business.business_type,
        description: business.description
      },
      token
    });

  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Login de negocio
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { email, password }: LoginRequest = value;

    // Buscar el negocio
    const client = await pool.connect();
    const result = await client.query(
      'SELECT * FROM businesses WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      client.release();
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    const business = result.rows[0];
    client.release();

    // Verificar contraseña
    const isValidPassword = await bcrypt.compare(password, business.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    // Generar token JWT
    const token = jwt.sign(
      { businessId: business.id, email: business.email },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login exitoso',
      business: {
        id: business.id,
        name: business.name,
        email: business.email,
        phone: business.phone,
        business_type: business.business_type,
        description: business.description,
        whatsapp_number: business.whatsapp_number
      },
      token
    });

  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Obtener perfil del negocio
router.get('/profile', async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ error: 'Token requerido' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    const client = await pool.connect();
    const result = await client.query(
      'SELECT id, name, email, phone, business_type, description, whatsapp_number, created_at FROM businesses WHERE id = $1',
      [decoded.businessId]
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Negocio no encontrado' });
    }

    res.json({ business: result.rows[0] });

  } catch (error) {
    console.error('Error obteniendo perfil:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

export default router; 