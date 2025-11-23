# ====================================
# Stage 1: Build de la aplicación React
# ====================================
FROM node:18-alpine AS build

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci --legacy-peer-deps

# Copiar el código fuente
COPY public ./public
COPY src ./src

# Construir la aplicación para producción
RUN npm run build

# ====================================
# Stage 2: Servir con Nginx
# ====================================
FROM nginx:stable-alpine

# Copiar archivos build desde stage anterior
COPY --from=build /app/build /usr/share/nginx/html

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 80
EXPOSE 80

# Healthcheck para verificar que nginx está funcionando
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Ejecutar nginx
CMD ["nginx", "-g", "daemon off;"]
