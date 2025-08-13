# 🧪 Prueba del Flujo de Onboarding - Vendex Claude

## 🎯 **Objetivo**
Probar el flujo completo de onboarding de un nuevo negocio, desde el registro hasta tener un asistente de ventas completamente funcional.

## 🚀 **Sistema en Ejecución**
- **Frontend:** http://localhost:3000
- **Backend:** http://localhost:3000
- **Health Check:** http://localhost:3000/health

## 📋 **Prerequisitos**

### **1. Credenciales de Prueba**

#### **UltraMsg (WhatsApp)**
- **Instance ID:** `1234567890` (prueba)
- **Token:** `abc123def456` (prueba)
- **Número WhatsApp:** `+1234567890` (prueba)

#### **Stripe (Pagos)**
- **Secret Key:** `sk_test_51ABC123DEF456` (prueba)
- **Publishable Key:** `pk_test_51ABC123DEF456` (prueba)
- **Webhook Secret:** `whsec_test123` (opcional, prueba)

#### **Anthropic (Claude AI)**
- **API Key:** `sk-ant-test123456789` (prueba)

## 🔄 **Flujo de Prueba Paso a Paso**

### **Paso 1: Acceder al Sistema**
1. Abre tu navegador
2. Ve a: `http://localhost:3000`
3. Deberías ver la pantalla de login/registro

### **Paso 2: Registrar un Nuevo Negocio**
1. Haz clic en "Registrarse" o "Crear cuenta"
2. Completa el formulario:
   ```
   Nombre del Negocio: "Tienda de Prueba"
   Email: "test@vendexclaude.com"
   Contraseña: "password123"
   Tipo de Negocio: "E-commerce"
   Descripción: "Tienda de prueba para testing"
   Teléfono: "+1234567890"
   ```
3. Haz clic en "Registrarse"
4. Deberías ser redirigido al onboarding

### **Paso 3: Onboarding - Paso 1: WhatsApp**
1. **Número de WhatsApp:** `+1234567890`
2. **UltraMsg Instance ID:** `1234567890`
3. **UltraMsg Token:** `abc123def456`
4. Haz clic en "Configurar WhatsApp"
5. Deberías avanzar al siguiente paso

### **Paso 4: Onboarding - Paso 2: Stripe**
1. **Stripe Secret Key:** `sk_test_51ABC123DEF456`
2. **Stripe Publishable Key:** `pk_test_51ABC123DEF456`
3. **Stripe Webhook Secret:** `whsec_test123` (opcional)
4. Haz clic en "Siguiente"
5. Deberías avanzar al siguiente paso

### **Paso 5: Onboarding - Paso 3: Asistente IA**
1. **Anthropic API Key:** `sk-ant-test123456789`
2. **Personalidad:** Selecciona "Amigable y cercano"
3. Haz clic en "Siguiente"
4. Deberías avanzar al siguiente paso

### **Paso 6: Onboarding - Paso 4: Productos**
1. Agrega al menos un producto:
   ```
   Nombre: "Producto de Prueba"
   Precio: 29.99
   Stock: 10
   Descripción: "Este es un producto de prueba para testing"
   ```
2. Haz clic en "Agregar Producto"
3. Haz clic en "Guardar Productos"
4. Deberías avanzar al paso final

### **Paso 7: Onboarding - Paso 5: Completado**
1. Revisa el resumen de configuración
2. Verifica que todos los elementos estén marcados como ✅
3. Haz clic en "¡Comenzar a Vender!"
4. Deberías ser redirigido al dashboard

## ✅ **Verificaciones de Éxito**

### **En el Dashboard**
- ✅ Deberías ver el nombre del negocio
- ✅ Estadísticas básicas (productos, conversaciones, ventas)
- ✅ Estado del asistente como "Activo"
- ✅ No deberías ver el onboarding nuevamente

### **En la Base de Datos**
```sql
-- Verificar que el negocio tenga todas las credenciales
SELECT 
  name,
  whatsapp_number,
  ultramsg_instance_id,
  ultramsg_token,
  stripe_secret_key,
  stripe_publishable_key,
  anthropic_api_key,
  assistant_personality,
  onboarding_completed,
  is_active
FROM businesses 
WHERE email = 'test@vendexclaude.com';
```

### **Verificar Productos**
```sql
-- Verificar que se crearon productos
SELECT 
  name,
  price,
  stock,
  description
FROM products 
WHERE business_id = (SELECT id FROM businesses WHERE email = 'test@vendexclaude.com');
```

## 🐛 **Posibles Errores y Soluciones**

### **Error 1: "No hay token de autenticación"**
**Causa:** Problema con JWT
**Solución:** Verificar que el backend esté ejecutándose correctamente

### **Error 2: "Error configurando WhatsApp"**
**Causa:** Credenciales de UltraMsg incorrectas
**Solución:** Usar las credenciales de prueba proporcionadas

### **Error 3: "Error configurando Stripe"**
**Causa:** Credenciales de Stripe incorrectas
**Solución:** Usar las credenciales de prueba proporcionadas

### **Error 4: "Error configurando Anthropic"**
**Causa:** API key de Anthropic incorrecta
**Solución:** Usar la API key de prueba proporcionada

### **Error 5: "Error guardando productos"**
**Causa:** Problema con la base de datos
**Solución:** Verificar conexión a Supabase

## 📊 **Métricas de Prueba**

### **Tiempo Esperado**
- **Registro:** 2-3 minutos
- **Onboarding completo:** 8-12 minutos
- **Total:** 10-15 minutos

### **Puntos de Verificación**
- ✅ Registro exitoso
- ✅ Redirección al onboarding
- ✅ Configuración de WhatsApp
- ✅ Configuración de Stripe
- ✅ Configuración de Anthropic
- ✅ Agregado de productos
- ✅ Completado de onboarding
- ✅ Acceso al dashboard
- ✅ Datos guardados en BD

## 🔧 **Configuración de Base de Datos**

### **Si usas Supabase:**
1. Ve a tu proyecto de Supabase
2. Ejecuta el SQL de `src/config/database.ts`
3. Verifica que las tablas se crearon correctamente

### **Si usas PostgreSQL local:**
1. Verifica que PostgreSQL esté ejecutándose
2. Las tablas se crean automáticamente al iniciar el backend

## 🎯 **Próximos Pasos Después de la Prueba**

### **1. Probar Funcionalidades**
- Enviar mensaje de prueba a WhatsApp
- Verificar respuesta del asistente
- Probar generación de link de pago

### **2. Configurar Credenciales Reales**
- Reemplazar credenciales de prueba con reales
- Configurar webhooks de Stripe
- Configurar webhook de UltraMsg

### **3. Personalización**
- Ajustar personalidad del asistente
- Agregar más productos
- Configurar notificaciones

## 📞 **Soporte**

Si encuentras problemas durante la prueba:

1. **Revisa los logs del backend** en la terminal
2. **Verifica la consola del navegador** para errores
3. **Comprueba la conexión a la base de datos**
4. **Verifica que todas las credenciales sean correctas**

## 🎉 **¡Listo para Probar!**

El flujo de onboarding está completamente implementado y listo para ser probado. Cada paso captura las credenciales necesarias y las almacena de forma segura por negocio.

**¡Comienza con el Paso 1 y disfruta del proceso! 🚀**
