# ⚡ Quick Start con Supabase - Vendex Claude

## 🚀 **Configuración en 5 minutos**

### **1. Crear Proyecto Supabase**

1. Ve a [supabase.com](https://supabase.com)
2. Crea cuenta con GitHub
3. **New Project**:
   - Name: `vendex-claude`
   - Password: Genera una segura
   - Region: El más cercano

### **2. Obtener Credenciales**

En **Settings → Database**:
```bash
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT_ID].supabase.co:5432/postgres
```

En **Settings → API**:
```bash
SUPABASE_URL=https://[PROJECT_ID].supabase.co
SUPABASE_ANON_KEY=[ANON_KEY]
SUPABASE_SERVICE_ROLE_KEY=[SERVICE_ROLE_KEY]
```

### **3. Crear Tablas**

Ve a **SQL Editor** y ejecuta:

```sql
-- Copia y pega todo este SQL
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

CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    sender_type VARCHAR(20) NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
```

### **4. Configurar .env**

```bash
# Copiar env.example
cp env.example .env

# Editar .env con tus credenciales
nano .env
```

```env
# Supabase
DATABASE_URL=postgresql://postgres:tu-password@db.tu-project-id.supabase.co:5432/postgres
SUPABASE_URL=https://tu-project-id.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key

# JWT
JWT_SECRET=tu-jwt-secret-super-seguro

# APIs (opcional para pruebas)
ANTHROPIC_API_KEY=sk-ant-...
ULTRAMSG_INSTANCE_ID=...
STRIPE_SECRET_KEY=sk_test_...
```

### **5. Probar Conexión**

```bash
# Instalar dependencias
npm install

# Probar conexión a Supabase
npm run test:db

# Iniciar backend
npm run dev
```

### **6. Iniciar Frontend**

```bash
# En otra terminal
cd frontend
flutter pub get
flutter run -d chrome
```

## 🎯 **APIs Opcionales para Pruebas**

### **Anthropic Claude**
- Ve a [console.anthropic.com](https://console.anthropic.com)
- Crea API key
- Agrega a `.env`

### **UltraMsg**
- Ve a [ultramsg.com](https://ultramsg.com)
- Crea cuenta
- Obtén credenciales

### **Stripe**
- Ve a [stripe.com](https://stripe.com)
- Crea cuenta
- Obtén test keys

## ✅ **Verificación**

1. **Backend corriendo**: http://localhost:3000/health
2. **Frontend corriendo**: http://localhost:3000
3. **Base de datos**: Ve a Supabase Dashboard → Table Editor

## 🎉 **¡Listo!**

Tu sistema está funcionando con:
- ✅ Backend Node.js
- ✅ Frontend Flutter
- ✅ Base de datos Supabase
- ✅ APIs configuradas

**¿Necesitas ayuda con algún paso específico?**
