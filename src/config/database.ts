import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

export const connectDB = async () => {
  try {
    const client = await pool.connect();
    console.log('✅ Base de datos conectada');
    client.release();
    
    // Crear tablas si no existen
    await createTables();
  } catch (error) {
    console.error('❌ Error conectando a la base de datos:', error);
    throw error;
  }
};

const createTables = async () => {
  const client = await pool.connect();
  
  try {
    // Tabla de negocios
    await client.query(`
      CREATE TABLE IF NOT EXISTS businesses (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        phone VARCHAR(20),
        business_type VARCHAR(100),
        description TEXT,
        stripe_secret_key VARCHAR(255),
        stripe_webhook_secret VARCHAR(255),
        whatsapp_number VARCHAR(20),
        assistant_personality TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tabla de productos
    await client.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        stock INTEGER DEFAULT 0,
        description TEXT,
        image_url VARCHAR(500),
        active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tabla de conversaciones
    await client.query(`
      CREATE TABLE IF NOT EXISTS conversations (
        id SERIAL PRIMARY KEY,
        business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
        customer_phone VARCHAR(20) NOT NULL,
        status VARCHAR(50) DEFAULT 'active',
        last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        context JSONB DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tabla de mensajes
    await client.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        sender_type VARCHAR(20) NOT NULL, -- 'customer' o 'assistant'
        message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'image', 'payment_link'
        metadata JSONB DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tabla de ventas
    await client.query(`
      CREATE TABLE IF NOT EXISTS sales (
        id SERIAL PRIMARY KEY,
        business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
        customer_phone VARCHAR(20) NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        stripe_payment_id VARCHAR(255),
        products JSONB NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    console.log('✅ Tablas creadas/verificadas');
  } catch (error) {
    console.error('❌ Error creando tablas:', error);
    throw error;
  } finally {
    client.release();
  }
};

export default pool; 