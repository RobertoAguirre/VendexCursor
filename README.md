# Vendex Claude - Asistente de Ventas WhatsApp

Sistema completo de asistente de ventas por WhatsApp que permite a cualquier negocio configurar un bot vendedor proactivo y efectivo con IA.

## 🚀 Características

- **Asistente IA Proactivo**: Claude Sonnet 4 que vende realmente, no solo responde
- **Integración WhatsApp**: Conexión directa con UltraMsg API
- **Gestión de Productos**: CRUD completo con inventario en tiempo real
- **Pagos Stripe**: Links de pago automáticos y webhooks
- **Dashboard Web**: Panel de administración completo
- **Multi-negocio**: Sistema SaaS escalable
- **Conversaciones Persistentes**: Contexto y seguimiento de clientes

## 🏗️ Arquitectura

### Backend (Node.js + TypeScript)
- **Express.js**: Servidor REST API
- **PostgreSQL**: Base de datos principal
- **JWT**: Autenticación segura
- **Claude AI**: Motor de IA para ventas
- **Stripe**: Procesamiento de pagos
- **UltraMsg**: Integración WhatsApp

### Frontend (Flutter)
- **Material Design**: UI moderna y responsive
- **State Management**: Gestión de estado eficiente
- **HTTP Client**: Comunicación con API
- **Local Storage**: Persistencia de datos

## 📋 Requisitos

- Node.js 18+
- PostgreSQL 14+
- Flutter 3.0+
- Cuenta UltraMsg
- API Key de Claude (Anthropic)
- Cuenta Stripe

## 🛠️ Instalación

### Backend

1. **Clonar repositorio**
```bash
git clone <repository-url>
cd VendexClaude
```

2. **Instalar dependencias**
```bash
npm install
```

3. **Configurar variables de entorno**
```bash
cp env.example .env
# Editar .env con tus credenciales
```

4. **Configurar base de datos**
```bash
# Crear base de datos PostgreSQL
createdb vendex_claude

# Las tablas se crean automáticamente al iniciar
```

5. **Ejecutar en desarrollo**
```bash
npm run dev
```

### Frontend (Flutter)

1. **Navegar al directorio**
```bash
cd frontend
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar API URL**
```dart
// lib/config/api_config.dart
const String baseUrl = 'http://localhost:3000/api';
```

4. **Ejecutar aplicación**
```bash
flutter run
```

## 🔧 Configuración

### Variables de Entorno (.env)

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://username:password@localhost:5432/vendex_claude

# JWT
JWT_SECRET=your-super-secret-jwt-key-here

# Stripe
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Anthropic (Claude)
ANTHROPIC_API_KEY=sk-ant-your_anthropic_api_key

# UltraMsg (WhatsApp)
ULTRAMSG_INSTANCE_ID=your_instance_id
ULTRAMSG_CLIENT_ID=your_client_id
ULTRAMSG_TOKEN=your_token

# Frontend URL
FRONTEND_URL=http://localhost:3000
```

## 📱 Uso

### Para Negocios

1. **Registro**: Crear cuenta con datos básicos
2. **Configuración**: Establecer tipo de negocio y descripción
3. **Productos**: Cargar catálogo de productos/servicios
4. **WhatsApp**: Conectar número de WhatsApp
5. **Stripe**: Configurar claves de API
6. **¡Listo!**: Asistente activo y vendiendo

### Para Clientes

1. **Escribir**: Mensaje al WhatsApp del negocio
2. **Conversar**: Asistente identifica intención de compra
3. **Recomendaciones**: Productos específicos sugeridos
4. **Pago**: Link de Stripe generado automáticamente
5. **Confirmación**: Venta completada y seguimiento

## 🔌 API Endpoints

### Autenticación
- `POST /api/auth/register` - Registro de negocio
- `POST /api/auth/login` - Login de negocio
- `GET /api/auth/profile` - Perfil del negocio

### Negocio
- `GET /api/business` - Información del negocio
- `PUT /api/business` - Actualizar negocio
- `POST /api/business/assistant-personality` - Configurar personalidad
- `POST /api/business/whatsapp` - Configurar WhatsApp
- `POST /api/business/stripe` - Configurar Stripe

### Productos
- `GET /api/products` - Listar productos
- `POST /api/products` - Crear producto
- `PUT /api/products/:id` - Actualizar producto
- `DELETE /api/products/:id` - Eliminar producto
- `PATCH /api/products/:id/stock` - Actualizar stock
- `POST /api/products/import` - Importar productos

### Conversaciones
- `GET /api/conversations` - Listar conversaciones
- `GET /api/conversations/:id` - Obtener conversación
- `GET /api/conversations/:id/messages` - Obtener mensajes
- `PATCH /api/conversations/:id/status` - Actualizar estado
- `GET /api/conversations/stats/summary` - Estadísticas

### WhatsApp
- `POST /api/whatsapp/webhook` - Webhook UltraMsg
- `POST /api/whatsapp/send` - Enviar mensaje
- `GET /api/whatsapp/conversations` - Conversaciones WhatsApp

### Stripe
- `POST /api/stripe/create-payment-link` - Crear link de pago
- `POST /api/stripe/webhook` - Webhook Stripe
- `GET /api/stripe/sales` - Listar ventas
- `GET /api/stripe/sales/stats` - Estadísticas de ventas

## 🧠 Motor de IA

El asistente utiliza Claude Sonnet 4 con:

- **Personalidad Adaptativa**: Según tipo de negocio
- **Contexto Persistente**: Memoria de conversaciones
- **Inventario Real**: Solo productos disponibles
- **Lógica de Ventas**: Proactivo y persuasivo
- **Generación de Pagos**: Links Stripe automáticos

## 📊 Métricas y Analytics

- Conversaciones activas/cerradas
- Tasa de conversión de ventas
- Ingresos por período
- Productos más vendidos
- Tiempo promedio de respuesta

## 🚀 Despliegue

### Backend (Producción)

1. **Build**
```bash
npm run build
```

2. **Variables de producción**
```env
NODE_ENV=production
DATABASE_URL=your_production_db_url
```

3. **PM2 (recomendado)**
```bash
npm install -g pm2
pm2 start dist/index.js --name vendex-backend
```

### Frontend (Producción)

```bash
flutter build web
# Desplegar en servidor web estático
```

## 🔒 Seguridad

- JWT para autenticación
- Rate limiting en APIs
- Validación de datos con Joi
- CORS configurado
- Helmet para headers de seguridad
- Sanitización de inputs

## 🧪 Testing

```bash
# Backend tests
npm test

# Frontend tests
flutter test
```

## 📈 Escalabilidad

- Arquitectura modular
- Base de datos optimizada
- Caching de respuestas IA
- Load balancing ready
- Microservicios preparados

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🆘 Soporte

- **Documentación**: [Wiki del proyecto]
- **Issues**: [GitHub Issues]
- **Email**: soporte@vendexclaude.com

## 🎯 Roadmap

- [ ] App móvil nativa
- [ ] Integración con más plataformas de pago
- [ ] Analytics avanzados
- [ ] Chatbot personalizable
- [ ] Integración con CRM
- [ ] Multiidioma
- [ ] API pública
- [ ] Marketplace de templates

---

**Vendex Claude** - Transformando conversaciones en ventas con IA 🤖💼 