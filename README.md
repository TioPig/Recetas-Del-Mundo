# API Recetas del Mundo

## 🚀 Inicio Rápido

### Ejecutar en modo desarrollo
```bash
# Perfil por defecto (desarrollo)
mvn spring-boot:run

# O especificar perfil desarrollo
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Ejecutar en modo producción
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

### Ejecutar con JAR
```bash
# Desarrollo
java -jar target/ms-recetas-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev

# Producción
java -jar target/ms-recetas-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
```

## 📋 Características Implementadas

### ✅ 1. Perfiles de Configuración
- **Desarrollo (`dev`)**: Logging detallado, SQL visible, configuración local
- **Producción (`prod`)**: Logging optimizado, configuración segura

### ✅ 2. Autenticación JWT
- Endpoints protegidos con JWT Bearer Token
- Configuración configurable desde properties
- Validación automática de tokens expirados

### ✅ 3. Documentación Swagger/OpenAPI
- Documentación completa en `/swagger-ui.html`
- Esquemas de seguridad JWT integrados
- Descripciones detalladas de endpoints
- Servidores configurados por perfil

### ✅ 4. Paginación
- Paginación automática en listas grandes
- Parámetros configurables: `page` y `size`
- Configuración por defecto y límites máximos
- Compatible con Spring Data Pageable

## 🔧 Configuración

### Variables de Entorno (Producción)
```bash
# Base de datos
DB_HOST=your-db-host
DB_PORT=5432
DB_NAME=recetas
DB_USERNAME=your-username
DB_PASSWORD=your-password

# JWT
JWT_SECRET=your-jwt-secret
JWT_EXPIRATION=7200000

# Flow Payment
FLOW_API_URL=https://api.flow.cl
FLOW_PUBLIC_KEY=your-public-key
FLOW_PRIVATE_KEY=your-private-key

# CORS
CORS_ALLOWED_ORIGINS=https://your-domain.com
```

## 📚 API Endpoints

### Recetas
- `GET /api/recetas?page=1&size=10` - Listar recetas paginadas
- `GET /api/recetas/all` - Listar todas las recetas (sin paginación)
- `GET /api/recetas/{id}` - Obtener receta por ID
- `GET /api/recetas/nombre/{nombre}` - Buscar por nombre
- `GET /api/recetas/pais/{id}` - Buscar por país
- `POST /api/recetas` - Crear receta (requiere JWT)
- `PUT /api/recetas/{id}` - Modificar receta (requiere JWT)
- `GET /api/recetas/count` - Contar total de recetas

### Autenticación
- `POST /api/usuarios/login` - Login (público)
- `POST /api/usuarios` - Registro (público)

### Documentación
- `GET /swagger-ui.html` - Interfaz Swagger UI
- `GET /v3/api-docs` - Especificación OpenAPI JSON

## 🛠️ Desarrollo

### Dependencias Clave
- Spring Boot 2.7.12
- Spring Security + JWT
- SpringDoc OpenAPI 1.7.0
- PostgreSQL + MongoDB
- Flyway (migraciones)

### Estructura del Proyecto
```
src/main/resources/
├── application.properties          # Configuración base
├── application-dev.properties     # Perfil desarrollo
└── application-prod.properties    # Perfil producción

src/main/java/cl/duoc/api/
├── config/                        # Configuraciones
│   ├── SecurityConfig.java        # Seguridad JWT
│   ├── OpenApiConfig.java         # Swagger/OpenAPI
│   └── PaginationConfig.java      # Paginación
├── controller/                    # Controladores REST
├── service/                       # Lógica de negocio
├── model/                         # Entidades y DTOs
└── util/                          # Utilidades (JWT)
```

## 📊 Base de Datos

### Diagrama Entidad-Relación
Ver archivos:
- `database_diagram.puml` - Diagrama PlantUML
- `database_diagram.md` - Diagrama Markdown
- `database_diagram_ascii.txt` - Diagrama ASCII

### Entidades Principales
- **Usuario**: Entidad central del sistema
- **Receta**: Recetas culinarias
- **Categoria**: Clasificación de recetas
- **Pais**: Origen de las recetas
- **RecetaLike/Comentario/Valoracion**: Interacciones

## 🔒 Seguridad

### Endpoints Públicos
- GET operations (lectura)
- `/swagger-ui/**`, `/v3/api-docs/**`
- `/api/usuarios/login`, `/api/usuarios` (POST)
- `/api/flow/**` (webhooks de pago)

### Endpoints Protegidos
- POST/PUT/PATCH/DELETE operations
- Endpoints de engagement (likes, comentarios)

### Autenticación
```bash
# Obtener token
curl -X POST http://localhost:8081/api/usuarios/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Usar token
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:8081/api/recetas
```

## 📈 Paginación

### Parámetros
- `page`: Número de página (comienza en 1)
- `size`: Elementos por página

### Ejemplos
```bash
# Página 1, 10 elementos
GET /api/recetas?page=1&size=10

# Página 2, 20 elementos
GET /api/recetas?page=2&size=20
```

### Configuración por Perfil
```properties
# Desarrollo
app.pagination.default-size=10
app.pagination.max-size=100

# Producción
app.pagination.default-size=20
app.pagination.max-size=50
```

## 🧪 Testing

### Ejecutar Tests
```bash
mvn test
```

### Ejecutar sin Tests
```bash
mvn clean package -DskipTests
```

## 📝 Logs

### Desarrollo
- SQL queries visibles
- Debug de seguridad
- Logs detallados de Spring

### Producción
- Solo logs de WARN/ERROR/INFO
- Sin SQL visible
- Optimizado para performance

## 🚀 Despliegue

### Variables de Entorno Requeridas
```bash
SPRING_PROFILES_ACTIVE=prod
DB_HOST=your-production-db
DB_USERNAME=your-db-user
DB_PASSWORD=your-db-password
JWT_SECRET=your-secure-jwt-secret
FLOW_PUBLIC_KEY=your-flow-public-key
FLOW_PRIVATE_KEY=your-flow-private-key
```

### Comando de Despliegue
```bash
java -jar ms-recetas-0.0.1-SNAPSHOT.jar \
  --spring.profiles.active=prod \
  --server.port=8080
```

---

**Versión**: 1.0.0
**Última actualización**: Septiembre 2025
**Perfil activo por defecto**: `dev`