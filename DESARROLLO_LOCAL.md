# 🚀 Desarrollo Local - Vendex Claude

Guía para ejecutar el sistema sin Docker, con backend y frontend independientes.

## 📋 **Requisitos Previos**

### **Sistema Operativo**
- Ubuntu 20.04+ / Debian 11+ / Linux Mint
- macOS 10.15+
- Windows 10+ (con WSL2 recomendado)

### **Software Requerido**
- **Node.js 18+** (para backend)
- **Flutter 3.0+** (para frontend)
- **PostgreSQL 14+** (base de datos)
- **Git** (control de versiones)

## 🛠️ **Instalación Paso a Paso**

### **1. Configurar Base de Datos**
```bash
# Ejecutar script de configuración de base de datos
./setup-database.sh
```

Este script:
- ✅ Instala PostgreSQL si no está instalado
- ✅ Crea usuario y base de datos
- ✅ Configura permisos
- ✅ Crea archivo `.env` con la configuración
- ✅ Verifica la conexión

### **2. Configurar Variables de Entorno**
```bash
# Editar archivo .env con tus credenciales
nano .env
```

**Variables requeridas:**
```env
# Base de datos (configurada automáticamente)
DATABASE_URL=postgresql://vendex_user:vendex_password@localhost:5432/vendex_claude

# JWT (generado automáticamente)
JWT_SECRET=tu-jwt-secret-aqui

# Anthropic (Claude AI) - REQUERIDO
ANTHROPIC_API_KEY=sk-ant-tu-api-key-aqui

# UltraMsg (WhatsApp) - REQUERIDO
ULTRAMSG_INSTANCE_ID=tu-instance-id
ULTRAMSG_CLIENT_ID=tu-client-id
ULTRAMSG_TOKEN=tu-token

# Stripe (Pagos) - REQUERIDO
STRIPE_SECRET_KEY=sk_test_tu-stripe-key
STRIPE_WEBHOOK_SECRET=whsec_tu-webhook-secret
```

### **3. Iniciar Backend**
```bash
# Terminal 1: Iniciar backend
./start-backend.sh
```

Este script:
- ✅ Verifica Node.js y PostgreSQL
- ✅ Instala dependencias si es necesario
- ✅ Verifica conexión a base de datos
- ✅ Inicia servidor en modo desarrollo
- ✅ Disponible en: http://localhost:3000

### **4. Iniciar Frontend**
```bash
# Terminal 2: Iniciar frontend
./start-frontend.sh
```

Este script:
- ✅ Verifica Flutter
- ✅ Instala dependencias
- ✅ Te permite elegir modo de ejecución:
  - **Web**: http://localhost:3000
  - **Android**: Dispositivo/emulador
  - **iOS**: Dispositivo/simulador
  - **Desktop**: Linux/Windows/macOS

## 🎯 **Flujo de Desarrollo**

### **Estructura de Directorios**
```
VendexClaude/
├── src/                    # Backend (Node.js/TypeScript)
│   ├── config/            # Configuración
│   ├── routes/            # Rutas API
│   ├── services/          # Servicios (Claude, Stripe)
│   ├── middleware/        # Middleware
│   └── types/             # Tipos TypeScript
├── frontend/              # Frontend (Flutter)
│   ├── lib/
│   │   ├── config/        # Configuración Flutter
│   │   ├── models/        # Modelos de datos
│   │   ├── providers/     # State management
│   │   └── screens/       # Pantallas de la app
│   └── assets/            # Imágenes, iconos, fuentes
├── uploads/               # Archivos subidos
├── .env                   # Variables de entorno
└── scripts/               # Scripts de inicio
```

### **Comandos Útiles**

#### **Backend**
```bash
# Instalar dependencias
npm install

# Modo desarrollo (con hot reload)
npm run dev

# Modo producción
npm run build
npm start

# Testear conexión a base de datos
npm run test:db

# Ejecutar tests
npm test
```

#### **Frontend**
```bash
# Navegar al directorio frontend
cd frontend

# Instalar dependencias
flutter pub get

# Ejecutar en web
flutter run -d chrome --web-port 3000

# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS
flutter run -d ios

# Ejecutar en desktop
flutter run -d linux

# Build para producción
flutter build web
```

## 🔧 **Configuración de APIs**

### **1. Anthropic (Claude AI)**
1. Ve a [console.anthropic.com](https://console.anthropic.com/)
2. Crea cuenta y obtén API key
3. Agrega en `.env`: `ANTHROPIC_API_KEY=sk-ant-...`

### **2. UltraMsg (WhatsApp)**
1. Ve a [ultramsg.com](https://ultramsg.com/)
2. Crea cuenta y configura instancia
3. Obtén credenciales y agrega en `.env`

### **3. Stripe (Pagos)**
1. Ve a [stripe.com](https://stripe.com/)
2. Crea cuenta y obtén claves
3. Configura webhook: `http://localhost:3000/api/stripe/webhook`
4. Agrega claves en `.env`

## 🐛 **Solución de Problemas**

### **Error de conexión a base de datos**
```bash
# Verificar que PostgreSQL esté corriendo
sudo systemctl status postgresql

# Reiniciar PostgreSQL
sudo systemctl restart postgresql

# Verificar conexión
npm run test:db
```

### **Error de puerto ocupado**
```bash
# Verificar qué está usando el puerto 3000
sudo lsof -i :3000

# Matar proceso si es necesario
sudo kill -9 <PID>
```

### **Error de Flutter**
```bash
# Verificar instalación
flutter doctor

# Limpiar cache
flutter clean
flutter pub get
```

### **Error de dependencias**
```bash
# Backend
rm -rf node_modules package-lock.json
npm install

# Frontend
cd frontend
flutter clean
flutter pub get
```

## 📱 **Modos de Ejecución**

### **Desarrollo Web (Recomendado)**
```bash
# Terminal 1: Backend
./start-backend.sh

# Terminal 2: Frontend
cd frontend
flutter run -d chrome --web-port 3000
```

### **Desarrollo Móvil**
```bash
# Conectar dispositivo Android/iOS
flutter devices

# Ejecutar en dispositivo
flutter run -d <device-id>
```

### **Desarrollo Desktop**
```bash
# Habilitar soporte desktop
flutter config --enable-linux-desktop

# Ejecutar
flutter run -d linux
```

## 🔄 **Flujo de Trabajo Recomendado**

1. **Configurar base de datos**: `./setup-database.sh`
2. **Configurar APIs**: Editar `.env`
3. **Iniciar backend**: `./start-backend.sh` (Terminal 1)
4. **Iniciar frontend**: `./start-frontend.sh` (Terminal 2)
5. **Desarrollar**: Modificar código y ver cambios en tiempo real
6. **Probar**: Usar la aplicación en http://localhost:3000

## 🎉 **¡Listo para Desarrollar!**

Con esta configuración tienes:
- ✅ **Backend Node.js** corriendo en puerto 3000
- ✅ **Frontend Flutter** disponible en web/móvil/desktop
- ✅ **Base de datos PostgreSQL** configurada
- ✅ **Hot reload** para desarrollo rápido
- ✅ **APIs integradas** (Claude, UltraMsg, Stripe)

**¡Tu asistente de ventas está listo para desarrollo! 🚀**
