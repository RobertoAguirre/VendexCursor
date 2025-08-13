#!/bin/bash

echo "🚀 Iniciando Vendex Claude Localmente"
echo "======================================"

# Verificar que esté configurado .env
if [ ! -f ".env" ]; then
    echo "❌ Error: Archivo .env no encontrado"
    echo "📝 Copia env.example a .env y configura tus credenciales:"
    echo "   cp env.example .env"
    echo "   nano .env"
    exit 1
fi

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js no está instalado"
    echo "📥 Instala Node.js desde: https://nodejs.org/"
    exit 1
fi

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no está instalado"
    echo "📥 Instala Flutter desde: https://flutter.dev/"
    exit 1
fi

echo "✅ Verificaciones completadas"

# Iniciar Backend
echo ""
echo "🔧 Iniciando Backend..."
echo "   Puerto: http://localhost:3000"
echo "   Health: http://localhost:3000/health"
echo ""

# Terminal 1: Backend
gnome-terminal --title="Backend - Vendex Claude" -- bash -c "
    echo '🚀 Iniciando Backend...'
    npm run dev
    read -p 'Presiona Enter para cerrar...'
"

# Esperar un momento para que el backend inicie
sleep 3

# Iniciar Frontend
echo ""
echo "🎨 Iniciando Frontend..."
echo "   URL: http://localhost:3000"
echo ""

# Terminal 2: Frontend
gnome-terminal --title="Frontend - Vendex Claude" -- bash -c "
    echo '🚀 Iniciando Frontend...'
    cd frontend
    flutter run -d chrome --web-port 3000
    read -p 'Presiona Enter para cerrar...'
"

echo ""
echo "🎉 ¡Vendex Claude iniciado!"
echo ""
echo "📱 URLs disponibles:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:3000"
echo "   Health:   http://localhost:3000/health"
echo ""
echo "🔧 Para detener: Cierra las terminales o presiona Ctrl+C"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Configura Supabase (base de datos)"
echo "   2. Edita .env con tus credenciales"
echo "   3. Registra tu primer negocio"
echo "   4. Completa el onboarding"
echo ""
