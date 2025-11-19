# 🔧 Configuración Frontend - Recetas Del Mundo

## 📍 Configuración Actual

### Desarrollo Local (localhost)
```bash
npm start
```
- **URL Frontend**: http://localhost:3000
- **URL Backend**: http://localhost:8081 (via proxy)
- **Archivo**: `.env.development`

### Producción (Servidor con Dominio)
```bash
npm run build
```
- **URL Frontend**: https://recetasdelmundo.site
- **URL Backend**: https://recetasdelmundo.site/api (proxy por Nginx del contenedor)
- **Archivo**: `.env.production`

**Nota**: El Nginx dentro del contenedor Docker maneja el proxy inverso `/api` → backend

---

## 🔄 Cómo Cambiar Entre Entornos

React automáticamente usa el archivo `.env` correcto según el comando:
- `npm start` → usa `.env.development`
- `npm run build` → usa `.env.production`

**No necesitas cambiar nada manualmente** ✅

---

## 📁 Archivos de Configuración

### `src/api.js`
```javascript
const API_BASE = process.env.NODE_ENV === 'production' 
  ? '/api'  // Producción - ruta relativa (nginx proxy)
  : '';  // Desarrollo (usa proxy)
```

### `.env.development` (Desarrollo Local)
```env
REACT_APP_API_URL=http://localhost:8081
REACT_APP_ENV=development
GENERATE_SOURCEMAP=true
```

### `.env.production` (Producción)
```env
REACT_APP_API_URL=/api
REACT_APP_ENV=production
GENERATE_SOURCEMAP=false
```

### `nginx.conf` (Contenedor Docker)

**IMPORTANTE**: El archivo `nginx.conf` tiene configuraciones diferentes para desarrollo y producción:

#### Desarrollo Local (Windows/Mac):
```bash
# Si estás en tu PC local, usa:
cp nginx.conf.dev nginx.conf
```

```nginx
# Proxy usa host.docker.internal
location /api/ {
  rewrite ^/api(.*)$ $1 break;
  proxy_pass http://host.docker.internal:8081;
}
```

#### Producción (Linux/Debian):
```bash
# Si despliegas al servidor, usa:
cp nginx.conf.prod nginx.conf
```

```nginx
# Proxy usa IP del gateway de Docker
location /api/ {
  rewrite ^/api(.*)$ $1 break;
  proxy_pass http://172.17.0.1:8081;
}
```

**Nota**: El archivo `nginx.conf` por defecto está configurado para PRODUCCIÓN.

### `package.json`
```json
{
  "proxy": "http://localhost:8081"  // Solo para desarrollo
}
```

---

## 🚀 Desplegar a Producción

### Opción 1: Build Local + Subir al Servidor
```bash
# 1. Construir en tu PC
npm run build

# 2. Copiar carpeta build al servidor
scp -r build/* admin@168.181.187.137:/ruta/al/proyecto/frontend/

# 3. Reconstruir Docker en el servidor
ssh admin@168.181.187.137
cd /ruta/al/proyecto
docker-compose build frontend
docker-compose up -d frontend
```

### Opción 2: Build Directo en Servidor (Recomendado)
```bash
# 1. Conectar al servidor
ssh admin@168.181.187.137

# 2. Ir al proyecto
cd /ruta/al/proyecto

# 3. Pull últimos cambios
git pull origin main

# 4. Reconstruir y reiniciar
docker-compose down
docker-compose build frontend
docker-compose up -d
```

---

## ✅ Verificar Configuración

### Desarrollo Local
1. Abre http://localhost:3000
2. Abre DevTools (F12) → Network
3. Las llamadas API deben ir a `http://localhost:8081`

### Producción
1. Abre https://recetasdelmundo.site
2. Abre DevTools (F12) → Network
3. Las llamadas API deben ir a `https://recetasdelmundo.site/api`

---

## 🔍 Troubleshooting

### Error: "ERR_CONNECTION_REFUSED"
**Problema**: Backend no está corriendo
**Solución**: 
```bash
docker-compose ps  # Verificar contenedores
docker-compose up -d backend  # Reiniciar backend
```

### Error: CORS en producción
**Problema**: Backend no permite el dominio
**Solución**: Actualizar `allowed.origins` en el backend:
```properties
allowed.origins=https://recetasdelmundo.site,https://www.recetasdelmundo.site
```

### Las llamadas van a localhost en producción
**Problema**: Build incorrecto o cache
**Solución**:
```bash
rm -rf build node_modules
npm install
npm run build
```

---

## 📝 Notas Importantes

1. **NO subas `.env.local`** a Git (ya está en .gitignore)
2. **Proxy solo funciona en desarrollo** (`npm start`)
3. **Producción siempre usa HTTPS** para seguridad
4. **Stripe requiere HTTPS** en producción
5. **Nginx en servidor** hace el routing `/api` → backend

---

## 🔗 URLs del Proyecto

### Desarrollo
- Frontend: http://localhost:3000
- Backend: http://localhost:8081
- Swagger: http://localhost:8081/swagger-ui/index.html

### Producción
- Frontend: https://recetasdelmundo.site
- Backend API: https://recetasdelmundo.site/api
- Swagger: https://recetasdelmundo.site/swagger-ui/index.html

---

**Última actualización**: 17 de noviembre de 2025
