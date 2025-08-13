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
        
        -- Stripe Configuration (por negocio)
        stripe_secret_key VARCHAR(255),
        stripe_webhook_secret VARCHAR(255),
        stripe_publishable_key VARCHAR(255),
        
        -- UltraMsg Configuration (por negocio)
        whatsapp_number VARCHAR(20),
        ultramsg_instance_id VARCHAR(255),
        ultramsg_token VARCHAR(255),
        
        -- AI Configuration (por negocio)
        anthropic_api_key VARCHAR(255),
        assistant_personality TEXT,
        
        -- Status
        is_active BOOLEAN DEFAULT true,
        onboarding_completed BOOLEAN DEFAULT false,
        
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
        customer_name VARCHAR(255),
        status VARCHAR(50) DEFAULT 'active',
        total_messages INTEGER DEFAULT 0,
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
        conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
        customer_phone VARCHAR(20) NOT NULL,
        customer_name VARCHAR(255),
        stripe_session_id VARCHAR(255),
        stripe_payment_intent_id VARCHAR(255),
        amount DECIMAL(10,2) NOT NULL,
        currency VARCHAR(3) DEFAULT 'USD',
        status VARCHAR(50) DEFAULT 'pending',
        products JSONB NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Índices para mejor rendimiento
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_businesses_email ON businesses(email);
      CREATE INDEX IF NOT EXISTS idx_products_business_id ON products(business_id);
      CREATE INDEX IF NOT EXISTS idx_conversations_business_id ON conversations(business_id);
      CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
      CREATE INDEX IF NOT EXISTS idx_sales_business_id ON sales(business_id);
      CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
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