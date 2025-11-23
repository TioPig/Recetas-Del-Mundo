# Recetas del Mundo — API

Resumen ejecutivo
------------------

`Recetas del Mundo` es una API REST diseñada para gestionar una colección curada de recetas, categorizadas por país y tipo, con un sistema completo de interacción social (comentarios, me gusta, favoritos y calificaciones). El proyecto está optimizado para producción con contenedores Docker, documentación OpenAPI y una arquitectura modular que facilita escalado y análisis.

Solución y oportunidad
----------------------

- Problema: la dispersión y baja calidad de contenido gastronómico dificulta el descubrimiento y la validación de recetas auténticas.
- Nuestra solución: una plataforma que combina datos normalizados, moderación por perfiles y métricas de interacción, facilitando descubrimiento y evaluación tanto para usuarios como investigadores.

Puntos clave para inversores
---------------------------

- Producto listo para demostración local y despliegue con `docker-compose`.
- Datos y validación: dataset realista con ~658 recetas activas y 8 ingredientes promedio por receta (métricas de validación interna).
- Monetización prevista: integraciones de pago (Stripe) para donaciones o contenido premium.

Audiencia académica
-------------------

El modelado de datos y las políticas de control de calidad permiten realizar estudios sobre normalización de recetas, análisis cultural por país, y métricas de interacción. El esquema relacional y las migraciones están documentadas en `docs/database_structure.sql` y las pruebas de integridad en `database/migrations`.

Arquitectura & diagramas
------------------------

Todos los diagramas fuente están en `docs/` en formato PlantUML (`*.puml`). Se incluyen:
- `docs/er_diagram_actualizado.puml` — Modelo entidad-relación principal.
- `docs/architecture_diagram.puml` — Arquitectura de alto nivel.
- `docs/auth_flow.puml` — Flujo de autenticación.
- `docs/endpoints_overview.puml` — Resumen de endpoints.

Para regenerar SVG/PNG vea `docs/README_DIAGRAMS.md`.

- Tecnologías principales
----------------------

- Backend: Node.js + Express (archivos `app.js`, `index.js`)
- Base de datos: PostgreSQL 15
- Contenedores: Docker & Docker Compose
- Documentación API: OpenAPI (especificación disponible vía Swagger UI cuando la aplicación está en marcha)
- Cache / sesiones: Redis (opcionalmente usado para sesiones y rate-limiting)
- Entrega y seguridad: reverse proxy (NGINX) con TLS/HTTPS para el sitio público
----------------------

- Backend: Node.js + Express (archivos `app.js`, `index.js`)
- Base de datos: PostgreSQL 15
- Contenedores: Docker & Docker Compose
- Documentación API: OpenAPI (especificación disponible vía Swagger UI cuando la aplicación está en marcha)

Instalación rápida (desarrollo)
-------------------------------
-------------------------------

Requisitos: `docker`, `docker-compose`, `PowerShell` (Windows)

```powershell
# 1) Construir y levantar servicios
docker-compose up --build -d

# 2) Ver logs del backend
docker-compose logs -f backend

# 3) Acceder a la API (ejemplo)
curl http://localhost:3000/recetas
```

Nota sobre HTTPS
----------------

En despliegues de producción se recomienda frontear la API y los assets estáticos con un reverse proxy (por ejemplo `nginx`) que gestione certificados TLS (Let's Encrypt) y redireccione tráfico HTTP a HTTPS. Si usa Docker Compose, puede añadir un servicio `nginx` o `traefik` para manejar TLS.

Ejemplo rápido (concepto):

```yaml
# fragmento de `docker-compose.yml` para referencia
services:
	nginx:
		image: nginx:stable
		ports:
			- "80:80"
			- "443:443"
		volumes:
			- ./nginx/conf.d:/etc/nginx/conf.d
			- ./certs:/etc/ssl/certs
		depends_on:
			- backend

	backend:
		build: .
		environment:
			- NODE_ENV=production
```

Si necesita, puedo generar ejemplos concretos de `nginx.conf` y archivos para Let's Encrypt.

Ejecución local sin Docker
--------------------------

1. Instalar dependencias: `npm install`
2. Configurar `config.js` (variables de BD, puerto)
3. Ejecutar: `npm start` o `node index.js`

-API y documentación
-------------------

- OpenAPI completa: disponible vía Swagger UI cuando la aplicación esté en marcha
- Endpoints detallados: `docs/ENDPOINTS-COMPLETOS.md`

Roadmap técnico (prioridades)
-----------------------------

1. Mejoras en la experiencia de búsqueda y recomendaciones.
2. Pipeline ETL para normalizar recetas y extraer metadatos nutricionales.
3. Dashboard analítico para métricas de interacción.

Contribución y estilo
----------------------

Por favor, antes de abrir un Pull Request:
- Ejecutar linters y pruebas (si aplican).
- Mantener el estilo del repositorio y documentar cambios en `README.md`.

Contacto
--------

Para presentaciones o reuniones con inversores, sugiere contactar a: `claudio@example.com` (sustituir por contacto real). Para soporte técnico usar issues en el repositorio.

Licencia
--------

Este repositorio se distribuye bajo la licencia MIT (si desea otra, actualizar aquí).
# 🍽️ API Recetas del Mundo — Resumen ejecutivo y guía técnica

Versión profesional del README, alineada con la presentación técnica en `docs/presentation_architecture.html`. Este documento está pensado para CTOs, equipos DevOps e inversores: resume la propuesta de valor, arquitectura, operaciones críticas y cómo arrancar el sistema.

## Resumen ejecutivo

API Recetas del Mundo es una API RESTful contenerizada, diseñada para producción con Docker y portable a Kubernetes. Ofrece:

- Backend modular en Spring Boot con autenticación JWT y hashing con BCrypt.
- Modelo relacional en PostgreSQL 15 optimizado para búsquedas por país y categoría.
- Funcionalidad social y de monetización: favoritos, comentarios, rating y donaciones.
- Estrategia operativa: imágenes reproducibles, Pipelines (integración y despliegue continuos), backups automáticos y pruebas de restore.

Estado actual: API operativa y validada (ver `docs/ENDPOINTS-COMPLETOS.md` para la lista completa — ~42 endpoints confirmados).

---

## Visión rápida

Este repositorio contiene el backend de "Recetas del Mundo": una API REST construida con Spring Boot y PostgreSQL que gestiona recetas, ingredientes, interacciones (favoritos, me gusta, estrellas, comentarios), usuarios, categorías y donaciones (Stripe).

---

## Contenido

- `Springboot/` — código del backend (Java, Maven).
-- `docs/` — documentación técnica: diagramas ER, SVGs de arquitectura y flujos, listas de tablas/columnas/constraints y guía de endpoints completa.
- `scripts/` — scripts para backup, E2E automatizados en PowerShell y utilidades.
- `database/` — utilitarios y conexión a la base de datos.

---

## Resumen rápido

- API lista para ejecución local en `http://localhost:8081`.
- Endpoints principales: `/auth`, `/usuarios`, `/categorias`, `/paises`, `/recetas` (incluye CRUD y muchas rutas de interacción).
- Documentación OpenAPI: disponible vía Swagger UI cuando la aplicación esté en marcha.

---

## Requisitos

- Java 21+ (el backend de esta rama se compiló y ejecuta con JDK 21)
- Maven 3.6+
- Docker
- Docker Compose (o `docker compose` integrado)
- PostgreSQL (solo si ejecutas la DB fuera de Docker)
- Spring Boot (solo para desarrollo local)

---

## Cómo ejecutar

### Compilar y ejecutar el JAR

1. Compila el proyecto:

```powershell
cd Springboot
mvn -DskipTests package
```

2. Ejecuta el JAR:

```powershell
java -jar target/api-recetas-0.0.1-SNAPSHOT.jar --server.port=8081
```

### Usar Docker Compose (si está configurado en la raíz)

```powershell
docker compose build backend
docker compose up -d backend
```

### Uso de docker-compose: `docker-compose.yml` vs `docker-compose.prod.yml`

Este repositorio mantiene dos archivos `docker-compose` con roles distintos:

- `docker-compose.yml` — Archivo principal pensado para desarrollo local. Contiene la sección `build:` para construir la imagen del backend desde `./Springboot`, monta el directorio `./database` para inicializadores y contiene valores por defecto para conveniencia (no recomendado para producción).
- `docker-compose.prod.yml` — Variante orientada a producción. Usa imágenes (campo `image`) en vez de `build`, declara volúmenes como `external` (espera que los volúmenes ya existan en el host) y no incluye valores por defecto sensibles — exige que proveas las variables de entorno.

Ejemplos de uso:

```powershell
# Desarrollo (con build local)
docker compose build backend
docker compose up -d

# Producción (usar archivo prod y un .env con variables seguras)
docker compose -f docker-compose.prod.yml --env-file .env up -d
```

Recomendaciones:

- No mantengas secretos en los archivos `docker-compose` ni en el repo. Usa `.env` (no versionado) o un gestor de secretos para valores sensibles (DB password, JWT secret, claves Stripe).
- `docker-compose.yml` es cómodo para desarrollo; `docker-compose.prod.yml` refleja el comportamiento esperado en despliegues (imágenes ya construidas, volúmenes administrados por la plataforma).
- Para entornos Windows use Git Bash o WSL cuando ejecute los scripts de backup/restore que dependen de utilidades POSIX (tar, mktemp). Hay un script PowerShell `scripts/restore_volumes_from_backup.ps1` para restauración de volúmenes desde Windows, pero la vía más robusta es ejecutar `scripts/restore_recetas_stack.sh` desde WSL/Git-Bash.

### Variables de entorno importantes

- `JWT_SECRET` — secreto para firmar JWT.
- `JWT_EXPIRATION_MS` — tiempo de expiración del token (ms).
- `DATABASE_URL` / `SPRING_DATASOURCE_*` — conexión a Postgres.
- `STRIPE_SECRET_KEY` — (opcional) para activar pagos/checkout real.

> Nota: No dejes claves en el repo. Usa variables de entorno o un archivo `.env` excluido en `.gitignore`.

---

-## Documentación de API

- Swagger/OpenAPI: la app expone `/swagger-ui/index.html` cuando está en marcha.
- Guía de endpoints completa (resumen y ejemplos): `docs/ENDPOINTS-COMPLETOS.md`.

### Endpoints destacados

- Autenticación: `POST /auth/login`, `POST /auth/register`.
- Recetas: `GET /recetas`, `GET /recetas/{id}`, `POST /recetas` (crear con ingredientes), `PUT /recetas/{id}`, `DELETE /recetas/{id}`.
- Interacciones centralizadas bajo `/recetas/*`: favoritos, me_gusta, estrellas, comentarios e ingredientes (agregar/actualizar/eliminar).
- Otros: `/categorias`, `/paises`, `/usuarios`.

Consulta `docs/ENDPOINTS-COMPLETOS.md` para la lista y ejemplos de uso.

---

## Diagramas (galería)

Los diagramas clave del proyecto (generados desde `docs/*.puml`) se listan a continuación en orden lógico. Para regenerarlos localmente use:

```powershell
.\scripts\generate_from_puml.ps1 -Width 1200
```

1. Arquitectura — visión general de componentes

	 ![Arquitectura](docs/architecture_diagram.png)

	 Muestra la composición del sistema (cliente, reverse proxy, backend, base de datos, backups). Útil para planear despliegue y operaciones.

2. Diagrama ER — modelo entidad-relación (integridad referencial)

	 ![Diagrama ER](docs/er_diagram.png)

	 Representa tablas, PKs, FKs e índices principales; referencia para migraciones y diseño de consultas.

3. Flujo de autenticación — proceso de login/registro

	 ![Flujo Auth](docs/auth_flow.png)

	 Describe emisión y uso de JWT, revocación y consideraciones de seguridad.

4. Endpoints — vista general de la API

	 ![Overview Endpoints](docs/endpoints_overview.png)

	 Mapa de los módulos expuestos por la API: `auth`, `usuarios`, `recetas`, `categorias`, `donaciones` y administración.

5. Detalles por módulo (endpoints)

	 - Usuarios

		 ![Usuarios Endpoints](docs/endpoints_usuarios.png)

	 - Recetas

		 ![Recetas Endpoints](docs/endpoints_recetas.png)

	 - Donaciones

		 ![Donaciones Endpoints](docs/endpoints_donaciones.png)

	 - Países y Categorías

		 ![Paises y Categorias](docs/endpoints_paises_categorias.png)

	 - Administración

		 ![Admin Endpoints](docs/endpoints_admin.png)

---

## Backups y restauración

- Hay scripts para backup en `scripts/` (PowerShell y bash). Los scripts principales son:

	- `scripts/backup_recetas_stack.sh` — crea un backup completo que incluye: imágenes Docker, dump SQL, configuración y (cuando se detectan) volúmenes. Resultado: `backups/complete_backup_YYYYMMDD_HHMMSS.tar.gz`.
	- `scripts/restore_recetas_stack.sh` — restaura imágenes, volúmenes y (opcionalmente) importa el dump SQL. Diseñado para ejecutarse en Linux/WSL/Git-Bash; acepta variables de entorno como `DEPLOY_DIR` y `COMPOSE_UP`.

- El dump SQL principal suele estar en `database/init.sql` (asegúrate que esté en UTF-8 sin BOM). Si tu dump tiene problemas de encoding conviértelo a UTF-8 antes de usarlo.

## Pruebas E2E

- Scripts E2E en PowerShell: `scripts/e2e_*.ps1`. Están preparados para ejecutarse contra `http://localhost:8081`.
- Variables útiles: `E2E_BASE_URL`, `E2E_EMAIL`, `E2E_PASSWORD`.

---

## Contacto

Equipo de desarrollo — `dev@recetas.cl` (consulta la documentación de la API vía Swagger UI para más metadatos de contacto).

---

## Conclusión

API Recetas del Mundo ofrece una base técnica sólida para productos culinarios digitales que requieren estabilidad, seguridad y capacidad de crecer a escala. Está pensada para equipos que necesitan una solución híbrida —capaz de coexistir con sistemas legacy y migrar hacia la nube— reduciendo riesgos operacionales y acelerando la entrega de valor.

Puntos clave:

- Despliegue reproducible (imágenes, Pipelines — integración y despliegue continuos).
- Escalabilidad horizontal mediante servicios stateless y réplicas.
- Operaciones seguras: gestión de secretos, backups automatizados y rotación.

© 2025 API Recetas del Mundo. Todos los derechos reservados.

