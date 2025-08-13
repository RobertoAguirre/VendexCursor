# 🧪 Prueba del Onboarding - Vendex Claude SaaS

## 🎯 **Objetivo**
Probar el flujo completo de onboarding como si fueras un cliente real del SaaS.

## 🚀 **Ejecutar el Sistema**

### **Terminal 1 - Backend**
```bash
npm run dev
```

### **Terminal 2 - Frontend**
```bash
cd frontend
flutter run -d chrome --web-port 8080
```

## 🌐 **URLs**
- **SaaS (Frontend):** http://localhost:8080
- **API (Backend):** http://localhost:3000

## 🧪 **Probar el Onboarding**

### **Paso 1: Acceder al SaaS**
1. Ve a: http://localhost:8080
2. Deberías ver la pantalla de login/registro

### **Paso 2: Registrar un Negocio**
```
Nombre: "Mi Tienda Online"
Email: "test@mitienda.com"
Contraseña: "password123"
Tipo: "E-commerce"
Descripción: "Tienda de productos digitales"
Teléfono: "+1234567890"
```

### **Paso 3: Onboarding - WhatsApp**
```
Número WhatsApp: +1234567890
UltraMsg Instance ID: 1234567890
UltraMsg Token: abc123def456
```

### **Paso 4: Onboarding - Stripe**
```
Secret Key: sk_test_51ABC123DEF456
Publishable Key: pk_test_51ABC123DEF456
Webhook Secret: whsec_test123 (opcional)
```

### **Paso 5: Onboarding - Asistente IA**
```
API Key: sk-ant-test123456789
Personalidad: "Amigable y cercano"
```

### **Paso 6: Onboarding - Productos**
```
Nombre: "Producto Digital Premium"
Precio: 49.99
Stock: 100
Descripción: "Producto digital de alta calidad"
```

### **Paso 7: Completar Onboarding**
- Revisar resumen de configuración
- Hacer clic en "¡Comenzar a Vender!"

## ✅ **Verificaciones de Éxito**

### **En el Dashboard**
- ✅ Nombre del negocio visible
- ✅ Estadísticas básicas (0 productos, 0 conversaciones, 0 ventas)
- ✅ Estado del asistente como "Activo"
- ✅ No aparece el onboarding nuevamente

## 🐛 **Solución de Problemas**

### **Backend no inicia**
```bash
# Verificar dependencias
npm install

# Verificar .env
cp env.example .env
# Editar .env con tus credenciales
```

### **Frontend no inicia**
```bash
# Verificar dependencias
cd frontend
flutter pub get

# Verificar Flutter
flutter doctor
```

### **Error de base de datos**
```bash
# Verificar conexión
npm run test:db
```

## 🎉 **¡Listo para Probar!**

**Comandos simples:**
- Terminal 1: `npm run dev`
- Terminal 2: `cd frontend && flutter run -d chrome --web-port 8080`
- Navegador: http://localhost:8080

**¡Experimenta el onboarding como un cliente real del SaaS! 🚀**
