# 🚀 Configuración con Supabase - Vendex Claude

## 📋 **Ventajas de Supabase**

- ✅ **Base de datos PostgreSQL** gestionada
- ✅ **Panel de administración** web
- ✅ **API REST automática**
- ✅ **Autenticación integrada** (opcional)
- ✅ **Tiempo real** con WebSockets
- ✅ **Gratis** hasta 500MB y 50,000 filas/mes

## 🎯 **Configuración Rápida**

### **1. Crear Proyecto en Supabase**

1. Ve a [supabase.com](https://supabase.com)
2. Crea cuenta con GitHub
3. Crea nuevo proyecto:
   - **Name**: `vendex-claude`
   - **Database Password**: Genera una segura
   - **Region**: El más cercano a ti

### **2. Obtener Credenciales**

En tu dashboard de Supabase:

```bash
# URL de conexión (Settings → Database)
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT_ID].supabase.co:5432/postgres

# API Keys (Settings → API)
SUPABASE_URL=https://[PROJECT_ID].supabase.co
SUPABASE_ANON_KEY=[ANON_KEY]
SUPABASE_SERVICE_ROLE_KEY=[SERVICE_ROLE_KEY]
```

### **3. Configurar Variables de Entorno**

```bash
# .env
DATABASE_URL=postgresql://postgres:tu-password@db.tu-project-id.supabase.co:5432/postgres
SUPABASE_URL=https://tu-project-id.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key
```

## 🗄️ **Crear Tablas en Supabase**

### **Opción 1: SQL Editor (Recomendado)**

Ve a **SQL Editor** en Supabase y ejecuta:

```sql
-- Tabla de negocios
CREATE TABLE IF NOT EXISTS businesses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    business_type VARCHAR(100),
    description TEXT,
    whatsapp_number VARCHAR(50),
    assistant_personality TEXT,
    stripe_secret_key VARCHAR(255),
    stripe_webhook_secret VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER DEFAULT 0,
    description TEXT,
    image_url TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de conversaciones
CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    customer_phone VARCHAR(50) NOT NULL,
    customer_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'active',
    total_messages INTEGER DEFAULT 0,
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de mensajes
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    sender_type VARCHAR(20) NOT NULL, -- 'customer' o 'assistant'
    message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'image', 'payment_link'
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de ventas
CREATE TABLE IF NOT EXISTS sales (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
    conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
    customer_phone VARCHAR(50) NOT NULL,
    customer_name VARCHAR(255),
    stripe_session_id VARCHAR(255),
    stripe_payment_intent_id VARCHAR(255),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'pending',
    products JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_businesses_email ON businesses(email);
CREATE INDEX IF NOT EXISTS idx_products_business_id ON products(business_id);
CREATE INDEX IF NOT EXISTS idx_conversations_business_id ON conversations(business_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_sales_business_id ON sales(business_id);
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
```

### **Opción 2: Table Editor (Visual)**

1. Ve a **Table Editor**
2. Crea cada tabla manualmente con los campos

## 🔧 **Configurar RLS (Row Level Security)**

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- Políticas para businesses (cada negocio ve solo sus datos)
CREATE POLICY "Businesses can view own data" ON businesses
    FOR SELECT USING (id = current_setting('app.business_id')::integer);

CREATE POLICY "Businesses can update own data" ON businesses
    FOR UPDATE USING (id = current_setting('app.business_id')::integer);

-- Políticas para products
CREATE POLICY "Businesses can manage own products" ON products
    FOR ALL USING (business_id = current_setting('app.business_id')::integer);

-- Políticas para conversations
CREATE POLICY "Businesses can manage own conversations" ON conversations
    FOR ALL USING (business_id = current_setting('app.business_id')::integer);

-- Políticas para messages
CREATE POLICY "Businesses can manage own messages" ON messages
    FOR ALL USING (
        conversation_id IN (
            SELECT id FROM conversations 
            WHERE business_id = current_setting('app.business_id')::integer
        )
    );

-- Políticas para sales
CREATE POLICY "Businesses can manage own sales" ON sales
    FOR ALL USING (business_id = current_setting('app.business_id')::integer);
```

## 🚀 **Configurar Backend**

### **1. Actualizar .env**

```env
# Supabase
DATABASE_URL=postgresql://postgres:tu-password@db.tu-project-id.supabase.co:5432/postgres
SUPABASE_URL=https://tu-project-id.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key

# Otras variables
JWT_SECRET=tu-jwt-secret
ANTHROPIC_API_KEY=sk-ant-...
ULTRAMSG_INSTANCE_ID=tu-instance-id
ULTRAMSG_CLIENT_ID=tu-client-id
ULTRAMSG_TOKEN=tu-token
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### **2. Probar Conexión**

```bash
# Verificar conexión
npm run test:db
```

## 🎯 **Ventajas para Desarrollo**

### **✅ Desarrollo Local**
- Base de datos en la nube
- No necesitas PostgreSQL local
- Datos persistentes entre sesiones

### **✅ Producción**
- Misma base de datos para dev/prod
- Escalabilidad automática
- Backups automáticos

### **✅ Monitoreo**
- Dashboard web para ver datos
- Logs de queries
- Métricas de rendimiento

## 🔄 **Migración desde PostgreSQL Local**

Si ya tienes datos locales:

```sql
-- Exportar desde PostgreSQL local
pg_dump -h localhost -U usuario -d database > backup.sql

-- Importar a Supabase
psql "postgresql://postgres:password@db.project.supabase.co:5432/postgres" < backup.sql
```

## 🎉 **¡Listo!**

Con Supabase tienes:
- ✅ Base de datos PostgreSQL gestionada
- ✅ Panel web para administrar datos
- ✅ API REST automática
- ✅ Escalabilidad automática
- ✅ Configuración en minutos

**¿Quieres que te ayude a configurar el proyecto en Supabase?**
