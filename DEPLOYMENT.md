# 🚀 Despliegue Vercel + Render - Vendex Claude

## 📋 **Arquitectura**
```
Frontend (Vercel) ←→ Backend (Render) ←→ PostgreSQL
```

## 🎯 **Backend en Render**

### **1. Preparar Repositorio**
- `render.yaml` ✅
- `package.json` con scripts ✅
- Variables de entorno configuradas

### **2. Configurar en Render**
1. Crear cuenta en [render.com](https://render.com)
2. Conectar repositorio GitHub
3. Crear Web Service:
   - Build: `npm install && npm run build`
   - Start: `npm start`
   - Plan: Starter (gratis)

### **3. Variables de Entorno**
```env
NODE_ENV=production
PORT=10000
DATABASE_URL=postgresql://...
JWT_SECRET=tu-secret
ANTHROPIC_API_KEY=sk-ant-...
ULTRAMSG_*=...
STRIPE_*=...
FRONTEND_URL=https://vendex-claude.vercel.app
```

## 🎯 **Frontend en Vercel**

### **1. Preparar Frontend**
- `vercel.json` ✅
- `build.yaml` ✅
- Configuración dinámica de API ✅

### **2. Configurar en Vercel**
1. Crear cuenta en [vercel.com](https://vercel.com)
2. Importar repositorio
3. Configurar:
   - Root: `frontend`
   - Build: `flutter build web --release`
   - Output: `build/web`

### **3. Variables de Entorno**
```env
API_BASE_URL=https://vendex-claude-backend.onrender.com/api
BACKEND_URL=https://vendex-claude-backend.onrender.com
FRONTEND_URL=https://vendex-claude.vercel.app
```

## 🔧 **Webhooks de Producción**

### **UltraMsg**
```
URL: https://vendex-claude-backend.onrender.com/api/whatsapp/webhook
```

### **Stripe**
```
URL: https://vendex-claude-backend.onrender.com/api/stripe/webhook
```

## 🚀 **Despliegue**

```bash
# 1. Commit cambios
git add .
git commit -m "Configuración para producción"
git push origin main

# 2. Render y Vercel detectarán automáticamente
# 3. URLs disponibles:
#    Frontend: https://vendex-claude.vercel.app
#    Backend: https://vendex-claude-backend.onrender.com
```

## 💰 **Costos**
- **Render**: Gratis (750h/mes)
- **Vercel**: Gratis (Hobby plan)

**¡Listo para producción! 🚀**
