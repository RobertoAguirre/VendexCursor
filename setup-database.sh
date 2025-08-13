#!/bin/bash

# Vendex Claude - Configurar Base de Datos
echo "🗄️ Configurando Base de Datos PostgreSQL..."

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si PostgreSQL está instalado
if ! command -v psql &> /dev/null; then
    print_warning "PostgreSQL no está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib
fi

# Verificar si PostgreSQL está corriendo
if ! pg_isready -q; then
    print_warning "PostgreSQL no está corriendo. Iniciando..."
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
fi

print_success "PostgreSQL está corriendo"

# Crear usuario y base de datos
print_status "Configurando usuario y base de datos..."

# Preguntar por credenciales
read -p "¿Quieres usar credenciales por defecto? (y/n): " use_default

if [ "$use_default" = "y" ] || [ "$use_default" = "Y" ]; then
    DB_USER="vendex_user"
    DB_PASS="vendex_password"
    DB_NAME="vendex_claude"
else
    read -p "Usuario de base de datos: " DB_USER
    read -s -p "Contraseña de base de datos: " DB_PASS
    echo
    read -p "Nombre de base de datos: " DB_NAME
fi

# Crear usuario
print_status "Creando usuario de base de datos..."
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null || print_warning "Usuario ya existe"

# Crear base de datos
print_status "Creando base de datos..."
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || print_warning "Base de datos ya existe"

# Dar permisos
print_status "Configurando permisos..."
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
sudo -u postgres psql -c "ALTER USER $DB_USER CREATEDB;"

print_success "Base de datos configurada"

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    print_status "Creando archivo .env..."
    cp env.example .env
    
    # Actualizar DATABASE_URL en .env
    sed -i "s|postgresql://username:password@localhost:5432/vendex_claude|postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME|g" .env
    
    print_success "Archivo .env creado con configuración de base de datos"
else
    print_warning "Archivo .env ya existe. Verifica que DATABASE_URL sea correcto:"
    print_warning "postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME"
fi

# Verificar conexión
print_status "Verificando conexión a la base de datos..."
if PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT 1;" >/dev/null 2>&1; then
    print_success "Conexión a la base de datos exitosa"
else
    print_error "Error conectando a la base de datos"
    print_warning "Verifica las credenciales y que PostgreSQL esté corriendo"
    exit 1
fi

echo ""
print_success "¡Base de datos configurada exitosamente!"
echo ""
echo "📋 Resumen de configuración:"
echo "   Usuario: $DB_USER"
echo "   Base de datos: $DB_NAME"
echo "   Host: localhost:5432"
echo "   URL: postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME"
echo ""
echo "🚀 Para iniciar el backend:"
echo "   ./start-backend.sh"
echo ""
echo "🚀 Para iniciar el frontend:"
echo "   ./start-frontend.sh"
