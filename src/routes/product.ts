import { Router, Request, Response } from 'express';
import Joi from 'joi';
import pool from '../config/database';
import { authenticateToken } from '../middleware/auth';
import { CreateProductRequest } from '../types';

const router = Router();

// Validación de esquemas
const createProductSchema = Joi.object({
  name: Joi.string().required().min(1).max(255),
  price: Joi.number().required().positive(),
  stock: Joi.number().integer().min(0).default(0),
  description: Joi.string().optional(),
  image_url: Joi.string().uri().optional()
});

const updateProductSchema = Joi.object({
  name: Joi.string().optional().min(1).max(255),
  price: Joi.number().optional().positive(),
  stock: Joi.number().integer().min(0).optional(),
  description: Joi.string().optional(),
  image_url: Joi.string().uri().optional(),
  active: Joi.boolean().optional()
});

// Obtener todos los productos del negocio
router.get('/', authenticateToken, async (req: any, res: Response) => {
  try {
    const businessId = req.business.id;
    const { active } = req.query;

    let query = 'SELECT * FROM products WHERE business_id = $1';
    const params = [businessId];

    if (active !== undefined) {
      query += ' AND active = $2';
      params.push(active === 'true');
    }

    query += ' ORDER BY created_at DESC';

    const client = await pool.connect();
    const result = await client.query(query, params);
    client.release();

    res.json({ products: result.rows });

  } catch (error) {
    console.error('Error obteniendo productos:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Obtener un producto específico
router.get('/:id', authenticateToken, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const businessId = req.business.id;

    const client = await pool.connect();
    const result = await client.query(
      'SELECT * FROM products WHERE id = $1 AND business_id = $2',
      [id, businessId]
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    res.json({ product: result.rows[0] });

  } catch (error) {
    console.error('Error obteniendo producto:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Crear nuevo producto
router.post('/', authenticateToken, async (req: any, res: Response) => {
  try {
    const { error, value } = createProductSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const businessId = req.business.id;
    const { name, price, stock, description, image_url }: CreateProductRequest = value;

    const client = await pool.connect();
    const result = await client.query(
      `INSERT INTO products (business_id, name, price, stock, description, image_url)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [businessId, name, price, stock, description, image_url]
    );
    client.release();

    res.status(201).json({
      message: 'Producto creado exitosamente',
      product: result.rows[0]
    });

  } catch (error) {
    console.error('Error creando producto:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Actualizar producto
router.put('/:id', authenticateToken, async (req: any, res: Response) => {
  try {
    const { error, value } = updateProductSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { id } = req.params;
    const businessId = req.business.id;

    const updateFields = Object.keys(value).map((key, index) => `${key} = $${index + 3}`).join(', ');
    const values = [id, businessId, ...Object.values(value)];

    const client = await pool.connect();
    const result = await client.query(
      `UPDATE products 
       SET ${updateFields}, updated_at = CURRENT_TIMESTAMP 
       WHERE id = $1 AND business_id = $2 
       RETURNING *`,
      values
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    res.json({
      message: 'Producto actualizado exitosamente',
      product: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando producto:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Eliminar producto (soft delete)
router.delete('/:id', authenticateToken, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const businessId = req.business.id;

    const client = await pool.connect();
    const result = await client.query(
      'UPDATE products SET active = false, updated_at = CURRENT_TIMESTAMP WHERE id = $1 AND business_id = $2 RETURNING *',
      [id, businessId]
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    res.json({
      message: 'Producto eliminado exitosamente',
      product: result.rows[0]
    });

  } catch (error) {
    console.error('Error eliminando producto:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Actualizar stock de producto
router.patch('/:id/stock', authenticateToken, async (req: any, res: Response) => {
  try {
    const { stock } = req.body;
    const { id } = req.params;
    const businessId = req.business.id;

    if (typeof stock !== 'number' || stock < 0) {
      return res.status(400).json({ error: 'Stock debe ser un número positivo' });
    }

    const client = await pool.connect();
    const result = await client.query(
      'UPDATE products SET stock = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND business_id = $3 RETURNING *',
      [stock, id, businessId]
    );
    client.release();

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    res.json({
      message: 'Stock actualizado exitosamente',
      product: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando stock:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Importar productos desde CSV (simplificado)
router.post('/import', authenticateToken, async (req: any, res: Response) => {
  try {
    const { products } = req.body;
    const businessId = req.business.id;

    if (!Array.isArray(products)) {
      return res.status(400).json({ error: 'Formato de productos inválido' });
    }

    const client = await pool.connect();
    const createdProducts = [];

    for (const product of products) {
      const { error } = createProductSchema.validate(product);
      if (error) {
        continue; // Saltar productos inválidos
      }

      const result = await client.query(
        `INSERT INTO products (business_id, name, price, stock, description, image_url)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [businessId, product.name, product.price, product.stock || 0, product.description, product.image_url]
      );
      
      createdProducts.push(result.rows[0]);
    }

    client.release();

    res.status(201).json({
      message: `${createdProducts.length} productos importados exitosamente`,
      products: createdProducts
    });

  } catch (error) {
    console.error('Error importando productos:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

export default router; 