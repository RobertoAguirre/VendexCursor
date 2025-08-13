#!/bin/bash

# Vendex Claude - Script de Instalación
echo "🚀 Instalando Vendex Claude..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado. Por favor instala Docker primero."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
        exit 1
    fi
    
    print_success "Docker y Docker Compose están instalados"
}

# Verificar si Node.js está instalado
check_nodejs() {
    if ! command -v node &> /dev/null; then
        print_warning "Node.js no está instalado. Instalando..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm no está instalado"
        exit 1
    fi
    
    print_success "Node.js y npm están instalados"
}

# Verificar si Flutter está instalado
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter no está instalado. Instalando..."
        git clone https://github.com/flutter/flutter.git -b stable ~/flutter
        export PATH="$PATH:~/flutter/bin"
        echo 'export PATH="$PATH:~/flutter/bin"' >> ~/.bashrc
        flutter doctor
    fi
    
    print_success "Flutter está instalado"
}

# Crear archivo .env
create_env_file() {
    if [ ! -f .env ]; then
        print_status "Creando archivo .env..."
        cat > .env << EOF
# Server
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://vendex_user:vendex_password@localhost:5432/vendex_claude

# JWT
JWT_SECRET=$(openssl rand -base64 32)

# Stripe (configurar después)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Anthropic (Claude) - REQUERIDO
ANTHROPIC_API_KEY=sk-ant-your_anthropic_api_key

# UltraMsg (WhatsApp) - REQUERIDO
ULTRAMSG_INSTANCE_ID=your_instance_id
ULTRAMSG_CLIENT_ID=your_client_id
ULTRAMSG_TOKEN=your_token

# File Upload
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880

# Frontend URL
FRONTEND_URL=http://localhost:3000
EOF
        print_success "Archivo .env creado"
        print_warning "Por favor configura las variables de entorno en .env"
    else
        print_status "Archivo .env ya existe"
    fi
}

# Instalar dependencias del backend
install_backend_deps() {
    print_status "Instalando dependencias del backend..."
    npm install
    print_success "Dependencias del backend instaladas"
}

# Instalar dependencias del frontend
install_frontend_deps() {
    print_status "Instalando dependencias del frontend..."
    cd frontend
    flutter pub get
    cd ..
    print_success "Dependencias del frontend instaladas"
}

# Crear directorios necesarios
create_directories() {
    print_status "Creando directorios necesarios..."
    mkdir -p uploads
    mkdir -p frontend/assets/images
    mkdir -p frontend/assets/icons
    mkdir -p frontend/assets/fonts
    print_success "Directorios creados"
}

# Iniciar servicios con Docker
start_services() {
    print_status "Iniciando servicios con Docker Compose..."
    docker-compose up -d postgres
    
    # Esperar a que PostgreSQL esté listo
    print_status "Esperando a que PostgreSQL esté listo..."
    sleep 10
    
    # Iniciar backend
    docker-compose up -d backend
    
    print_success "Servicios iniciados"
    print_status "Backend disponible en: http://localhost:3000"
    print_status "Frontend disponible en: http://localhost:80"
}

# Mostrar información de configuración
show_config_info() {
    echo ""
    echo "🎉 ¡Instalación completada!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. Configura las variables de entorno en .env:"
    echo "   - ANTHROPIC_API_KEY (obtener en https://console.anthropic.com/)"
    echo "   - ULTRAMSG_* (obtener en https://ultramsg.com/)"
    echo "   - STRIPE_* (obtener en https://stripe.com/)"
    echo ""
    echo "2. Inicia los servicios:"
    echo "   docker-compose up -d"
    echo ""
    echo "3. Accede a la aplicación:"
    echo "   Frontend: http://localhost"
    echo "   API: http://localhost:3000"
    echo ""
    echo "📚 Documentación: README.md"
    echo ""
}

# Función principal
main() {
    print_status "Iniciando instalación de Vendex Claude..."
    
    # Verificar dependencias
    check_docker
    check_nodejs
    check_flutter
    
    # Crear archivos y directorios
    create_env_file
    create_directories
    
    # Instalar dependencias
    install_backend_deps
    install_frontend_deps
    
    # Iniciar servicios
    start_services
    
    # Mostrar información
    show_config_info
}

# Ejecutar función principal
main "$@" 