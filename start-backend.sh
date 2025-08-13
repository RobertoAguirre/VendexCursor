#!/bin/bash

# Vendex Claude - Iniciar Backend
echo "🚀 Iniciando Backend Vendex Claude..."

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    print_warning "Node.js no está instalado. Instalando..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Verificar si PostgreSQL está corriendo
if ! pg_isready -q; then
    print_warning "PostgreSQL no está corriendo. Iniciando..."
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
fi

# Verificar si existe archivo .env
if [ ! -f .env ]; then
    print_warning "Archivo .env no encontrado. Creando desde ejemplo..."
    cp env.example .env
    print_warning "Por favor configura las variables de entorno en .env antes de continuar"
    print_warning "Especialmente: DATABASE_URL, ANTHROPIC_API_KEY, ULTRAMSG_*, STRIPE_*"
    exit 1
fi

# Instalar dependencias si no existen
if [ ! -d "node_modules" ]; then
    print_status "Instalando dependencias..."
    npm install
fi

# Crear directorio de uploads si no existe
mkdir -p uploads

# Verificar conexión a la base de datos
print_status "Verificando conexión a la base de datos..."
if npm run test:db 2>/dev/null; then
    print_success "Base de datos conectada"
else
    print_warning "Error conectando a la base de datos"
    print_warning "Verifica tu DATABASE_URL en .env"
    print_warning "Ejemplo: postgresql://usuario:password@localhost:5432/vendex_claude"
    exit 1
fi

# Iniciar servidor en modo desarrollo
print_status "Iniciando servidor backend en modo desarrollo..."
print_success "Backend disponible en: http://localhost:3000"
print_success "API disponible en: http://localhost:3000/api"
print_success "Health check: http://localhost:3000/health"

npm run dev
