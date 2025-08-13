# Etapa de build
FROM debian:latest AS build-env

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Instalar Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Verificar instalación
RUN flutter doctor -v

# Copiar código fuente
WORKDIR /app
COPY . .

# Obtener dependencias
RUN flutter pub get

# Build para web
RUN flutter build web --release

# Etapa de producción con Nginx
FROM nginx:alpine

# Copiar archivos buildados
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copiar configuración de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto
EXPOSE 80

# Comando de inicio
CMD ["nginx", "-g", "daemon off;"] 