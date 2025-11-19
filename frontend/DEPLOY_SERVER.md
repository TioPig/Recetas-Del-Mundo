# 🚀 Guía de Despliegue al Servidor con HTTPS

Esta guía te ayudará a desplegar el frontend en el servidor para que funcione con HTTPS usando la configuración del documento CONFIGURACION_DOMINIO.

## 📋 Cambios Realizados

El **nginx interno del contenedor** ahora solo sirve archivos estáticos.
El **Nginx del servidor** maneja:
- SSL/HTTPS
- Proxy al frontend (archivos estáticos)
- Proxy al backend (API en puerto 8081)

## 🏗️ Arquitectura

```
Internet (HTTPS/HTTP)
    ↓
Nginx del Servidor (puerto 80/443)
    ├── / → Contenedor Frontend (puerto 80) → Archivos React
    └── /api → Backend directo (puerto 8081)
```

## 🔨 Paso 1: Construir Nueva Imagen

Desde tu PC local (Windows):

```powershell
# Navegar al frontend
cd "f:\Cosas IO\Repositorios\Recetas-Del-Mundo\frontend"

# Construir imagen
docker build -t tiopig1324/recetas-frontend:latest .

# Subir a Docker Hub
docker push tiopig1324/recetas-frontend:latest
```

## 🖥️ Paso 2: Configurar el Servidor

Conéctate al servidor:

```bash
ssh root@168.181.187.137
```

### 2.1. Detener contenedor actual

```bash
docker stop recetas-frontend
docker rm recetas-frontend
```

### 2.2. Crear red Docker (si no existe)

```bash
docker network create recetas-network
```

### 2.3. Descargar nueva imagen y correr contenedor

```bash
# Descargar última versión
docker pull tiopig1324/recetas-frontend:latest

# Correr SIN exponer puerto 80 externamente
docker run -d \
  --name recetas-frontend \
  --network recetas-network \
  --restart unless-stopped \
  tiopig1324/recetas-frontend:latest
```

### 2.4. Conectar backend a la misma red (si no está)

```bash
docker network connect recetas-network api-recetas-backend
```

### 2.5. Configurar Nginx del Servidor

```bash
sudo nano /etc/nginx/sites-available/recetas-del-mundo
```

**Pegar esta configuración (del documento CONFIGURACION_DOMINIO):**

```nginx
# Configuración HTTP (se actualizará automáticamente a HTTPS por Certbot)
server {
    listen 80;
    listen [::]:80;
    server_name recetasdelmundo.site www.recetasdelmundo.site;

    # Logs
    access_log /var/log/nginx/recetas-access.log;
    error_log /var/log/nginx/recetas-error.log;

    # Aumentar tamaño máximo de upload (para imágenes de recetas)
    client_max_body_size 50M;

    # Frontend React (Puerto 80 del contenedor Docker)
    location / {
        proxy_pass http://recetas-frontend:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Backend API Spring Boot (Puerto 8081)
    location /api {
        # Reescribir /api/recetas → /recetas
        rewrite ^/api(.*)$ $1 break;
        
        proxy_pass http://localhost:8081;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts para API
        proxy_connect_timeout 90s;
        proxy_send_timeout 90s;
        proxy_read_timeout 90s;
    }

    # Swagger UI - Documentación de API (Puerto 8081)
    location /swagger-ui {
        proxy_pass http://localhost:8081/swagger-ui;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # OpenAPI JSON
    location /v3/api-docs {
        proxy_pass http://localhost:8081/v3/api-docs;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

### 2.6. Activar configuración de Nginx

```bash
# Crear enlace simbólico
sudo ln -sf /etc/nginx/sites-available/recetas-del-mundo /etc/nginx/sites-enabled/

# Eliminar default
sudo rm -f /etc/nginx/sites-enabled/default

# Verificar sintaxis
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```

### 2.7. Obtener Certificado SSL (HTTPS)

```bash
sudo certbot --nginx -d recetasdelmundo.site -d www.recetasdelmundo.site
```

**Responder:**
1. Email: tu-email@ejemplo.com
2. Términos: A (aceptar)
3. Marketing: N (no)
4. Redirección HTTPS: 2 (Redirect)

### 2.8. Verificar certificado

```bash
sudo certbot certificates
sudo certbot renew --dry-run
```

## ✅ Paso 3: Verificación

### En el servidor:

```bash
# Ver contenedores
docker ps

# Ver logs
docker logs recetas-frontend
docker logs api-recetas-backend

# Probar endpoints
curl http://localhost:80
curl http://recetas-frontend:80
curl http://localhost:8081/recetas
curl https://recetasdelmundo.site
```

### En el navegador:

1. Abre `https://recetasdelmundo.site`
2. Debe mostrar candado verde (SSL válido)
3. F12 → Console → Sin errores de CORS
4. F12 → Network → Las peticiones van a `https://recetasdelmundo.site/api/...`

## 🔧 Troubleshooting

### Error: "502 Bad Gateway"

```bash
# Ver si contenedor está corriendo
docker ps | grep recetas-frontend

# Ver logs
docker logs recetas-frontend

# Reiniciar
docker restart recetas-frontend
sudo systemctl restart nginx
```

### Error: "CORS Policy"

El backend necesita tener configurado en `application.properties`:

```properties
allowed.origins=https://recetasdelmundo.site,https://www.recetasdelmundo.site
```

**NO puedes modificar el backend**, así que el administrador del backend debe hacer esto.

### Error: Puerto 80 en uso

```bash
# Ver qué usa el puerto 80
sudo lsof -i :80

# Detener contenedor si está exponiendo puerto
docker stop recetas-frontend
docker rm recetas-frontend
# Volver a crear sin -p 80:80
```

## 📝 Notas Importantes

1. **El contenedor frontend NO expone puerto 80 externamente** (sin `-p 80:80`)
2. **El Nginx del servidor** es quien escucha en 80/443
3. **El backend NO necesita cambios** si ya está en puerto 8081
4. **Las peticiones API** van: Browser → Nginx Servidor (HTTPS) → Backend (HTTP:8081)
5. **Las peticiones frontend** van: Browser → Nginx Servidor → Contenedor Frontend

## 🎯 Checklist Final

- [ ] Imagen construida y subida a Docker Hub
- [ ] Contenedor frontend recreado SIN exponer puerto 80
- [ ] Nginx del servidor configurado
- [ ] Certificado SSL obtenido
- [ ] `https://recetasdelmundo.site` carga con candado verde
- [ ] API funciona en `https://recetasdelmundo.site/api/recetas`
- [ ] Sin errores de CORS en consola
- [ ] Swagger accesible en `https://recetasdelmundo.site/swagger-ui/index.html`

---

**Fecha:** 18 de noviembre de 2025  
**Proyecto:** Recetas Del Mundo  
**Configuración:** Nginx del servidor maneja SSL y proxy
