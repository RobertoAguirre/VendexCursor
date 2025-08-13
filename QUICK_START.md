# 🚀 Inicio Rápido - Vendex Claude

## Instalación Automática (Recomendada)

```bash
# Clonar repositorio
git clone <tu-repositorio>
cd VendexClaude

# Ejecutar instalación automática
./install.sh
```

## Instalación Manual

### 1. Requisitos Previos
- Docker y Docker Compose
- Node.js 18+
- Flutter 3.0+

### 2. Configurar Variables de Entorno
```bash
cp env.example .env
# Editar .env con tus credenciales
```

### 3. Instalar Dependencias
```bash
# Backend
npm install

# Frontend
cd frontend
flutter pub get
cd ..
```

### 4. Iniciar Servicios
```bash
# Con Docker (recomendado)
docker-compose up -d

# Sin Docker
npm run dev  # Backend
cd frontend && flutter run -d chrome  # Frontend
```

## 🔑 Configuración Requerida

### 1. Anthropic (Claude AI)
1. Ve a [console.anthropic.com](https://console.anthropic.com/)
2. Crea una cuenta y obtén tu API key
3. Agrega en `.env`: `ANTHROPIC_API_KEY=sk-ant-tu-api-key`

### 2. UltraMsg (WhatsApp)
1. Ve a [ultramsg.com](https://ultramsg.com/)
2. Crea una cuenta y configura tu instancia
3. Agrega en `.env`:
   ```
   ULTRAMSG_INSTANCE_ID=tu_instance_id
   ULTRAMSG_CLIENT_ID=tu_client_id
   ULTRAMSG_TOKEN=tu_token
   ```

### 3. Stripe (Pagos)
1. Ve a [stripe.com](https://stripe.com/)
2. Crea una cuenta y obtén las claves
3. Agrega en `.env`:
   ```
   STRIPE_SECRET_KEY=sk_test_tu_stripe_key
   STRIPE_WEBHOOK_SECRET=whsec_tu_webhook_secret
   ```

## 📱 Uso Básico

### 1. Registro de Negocio
1. Abre http://localhost
2. Haz clic en "Regístrate"
3. Completa los datos del negocio
4. ¡Listo!

### 2. Configurar Productos
1. Ve a "Productos" en el dashboard
2. Agrega tus productos con precios y stock
3. Sube imágenes si es necesario

### 3. Conectar WhatsApp
1. Ve a "Configuración" > "WhatsApp"
2. Ingresa tu número de WhatsApp
3. El asistente estará activo

### 4. Configurar Pagos
1. Ve a "Configuración" > "Stripe"
2. Ingresa tus claves de Stripe
3. Los links de pago se generarán automáticamente

## 🧠 Personalizar el Asistente

### Configurar Personalidad
1. Ve a "Configuración" > "Asistente"
2. Escribe la personalidad deseada, ejemplo:
   ```
   Eres un vendedor amigable y profesional para mi florería. 
   Te llamas Rosa y siempre recomiendas las mejores flores 
   según la ocasión. Eres proactivo pero no agresivo.
   ```

## 📊 Monitoreo

### Dashboard Principal
- Conversaciones activas
- Ventas del día/mes
- Productos más vendidos
- Ingresos totales

### Conversaciones
- Ver todas las conversaciones
- Leer mensajes completos
- Marcar como cerradas
- Buscar por cliente

### Ventas
- Historial de ventas
- Estado de pagos
- Productos vendidos
- Ingresos por período

## 🔧 Comandos Útiles

```bash
# Ver logs del backend
docker-compose logs backend

# Reiniciar servicios
docker-compose restart

# Parar todos los servicios
docker-compose down

# Ver estado de servicios
docker-compose ps

# Actualizar código
git pull
docker-compose up -d --build
```

## 🆘 Solución de Problemas

### Error de conexión a la base de datos
```bash
# Verificar que PostgreSQL esté corriendo
docker-compose ps postgres

# Reiniciar PostgreSQL
docker-compose restart postgres
```

### Error de autenticación
- Verifica que las API keys estén correctas en `.env`
- Revisa los logs: `docker-compose logs backend`

### WhatsApp no responde
- Verifica la configuración de UltraMsg
- Asegúrate de que el webhook esté configurado
- Revisa los logs de WhatsApp

### Pagos no funcionan
- Verifica las claves de Stripe
- Asegúrate de que el webhook esté configurado
- Revisa los logs de Stripe

## 📞 Soporte

- **Documentación**: README.md
- **Issues**: GitHub Issues
- **Email**: soporte@vendexclaude.com

---

**¡Tu asistente de ventas está listo para vender! 🎉** 