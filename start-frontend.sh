#!/bin/bash

# Vendex Claude - Iniciar Frontend
echo "🚀 Iniciando Frontend Vendex Claude..."

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

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    print_warning "Flutter no está instalado. Instalando..."
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    export PATH="$PATH:~/flutter/bin"
    echo 'export PATH="$PATH:~/flutter/bin"' >> ~/.bashrc
    source ~/.bashrc
    flutter doctor
fi

# Navegar al directorio frontend
cd frontend

# Verificar si Flutter está configurado correctamente
print_status "Verificando configuración de Flutter..."
flutter doctor

# Instalar dependencias
print_status "Instalando dependencias de Flutter..."
flutter pub get

# Verificar configuración de API
print_status "Verificando configuración de API..."
if grep -q "localhost:3000" lib/config/api_config.dart; then
    print_success "API configurada para localhost:3000"
else
    print_warning "Verifica la configuración de API en lib/config/api_config.dart"
fi

# Crear directorios de assets si no existen
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts

# Iniciar aplicación Flutter
print_status "Iniciando aplicación Flutter..."
print_success "Frontend disponible en: http://localhost:3000 (web)"
print_success "O en tu dispositivo móvil conectado"
print_warning "Asegúrate de que el backend esté corriendo en http://localhost:3000"

# Preguntar en qué modo ejecutar
echo ""
echo "¿En qué modo quieres ejecutar Flutter?"
echo "1) Web (navegador)"
echo "2) Android (dispositivo/emulador)"
echo "3) iOS (dispositivo/simulador)"
echo "4) Desktop (Linux/Windows/macOS)"
read -p "Selecciona una opción (1-4): " choice

case $choice in
    1)
        print_status "Ejecutando en modo web..."
        flutter run -d chrome --web-port 3000
        ;;
    2)
        print_status "Ejecutando en Android..."
        flutter run -d android
        ;;
    3)
        print_status "Ejecutando en iOS..."
        flutter run -d ios
        ;;
    4)
        print_status "Ejecutando en desktop..."
        flutter run -d linux
        ;;
    *)
        print_warning "Opción inválida. Ejecutando en modo web por defecto..."
        flutter run -d chrome --web-port 3000
        ;;
esac
