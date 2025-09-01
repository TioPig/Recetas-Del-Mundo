# 🚀 INSTRUCCIONES PARA SUBIR A GITHUB
## API Recetas del Mundo

### 📋 PASO 1: Instalar Git
1. Ve a: https://git-scm.com/downloads
2. Descarga la versión para Windows
3. Instala con las opciones por defecto
4. Reinicia la terminal/PowerShell

### 📋 PASO 2: Crear Repositorio en GitHub
1. Ve a: https://github.com/new
2. **Nombre del repositorio:** `api-recetas-del-mundo`
3. **Descripción:** `API REST completa para sistema de recetas culinarias con JWT, Swagger y paginación`
4. **Visibilidad:** Pública (recomendado para compartir con tu colega)
5. Haz clic en **"Create repository"**

### 📋 PASO 3: Preparar y Subir el Código

#### Opción A: Usar script automático (recomendado)
```bash
# Una vez instalado Git, ejecuta:
cd C:\GitHub\api-recetas_del_mundo
.\prepare_github.bat
```

#### Opción B: Comandos manuales
```bash
# Navegar al directorio del proyecto
cd C:\GitHub\api-recetas_del_mundo

# Inicializar repositorio Git
git init

# Agregar todos los archivos
git add .

# Crear commit inicial
git commit -m "Initial commit: API Recetas del Mundo v1.0.0

✅ Características implementadas:
- Perfiles de desarrollo y producción
- Autenticación JWT completa
- Documentación Swagger/OpenAPI
- Paginación automática
- Base de datos PostgreSQL + MongoDB
- Diagramas de base de datos completos
- Scripts de automatización

📦 Contenido:
- Backend Spring Boot completo
- Configuraciones por perfil
- Scripts de inicio (Windows/Linux)
- Documentación completa
- Diagramas de base de datos
- Backup de base de datos incluido"

# Cambiar nombre de rama a main
git branch -M main
```

### 📋 PASO 4: Conectar con GitHub y Subir
```bash
# Conectar con tu repositorio (reemplaza TU_USUARIO con tu username de GitHub)
git remote add origin https://github.com/TU_USUARIO/api-recetas-del-mundo.git

# Subir el código
git push -u origin main
```

### 📋 PASO 5: Invitar a tu Colega
1. Ve a tu repositorio en GitHub
2. Haz clic en **Settings** → **Collaborators**
3. Busca el username de GitHub de tu colega
4. Envía la invitación

### 📋 PASO 6: Tu Colega Puede Clonar
Tu colega podrá ejecutar:
```bash
git clone https://github.com/TU_USUARIO/api-recetas-del-mundo.git
```

## 🔧 COMANDOS DE VERIFICACIÓN

### Ver estado del repositorio
```bash
git status
git log --oneline
```

### Ver archivos incluidos
```bash
git ls-files | head -20
```

### Ver tamaño del repositorio
```bash
git count-objects -vH
```

## 📊 LO QUE SE SUBIRÁ A GITHUB

### ✅ Archivos Incluidos
- `Springboot/` - Todo el backend
- `README.md` - Documentación completa
- `start.bat` / `start.sh` - Scripts de inicio
- `database_diagram.*` - Diagramas de BD
- `.gitignore` - Exclusiones de Git
- `prepare_github.*` - Scripts de preparación

### ❌ Archivos Excluidos (por .gitignore)
- `target/` - Archivos compilados
- `*.log` - Logs de aplicación
- `backup_*/` - Backups locales
- `application-prod.properties` - Configuración sensible

## 🎯 CARACTERÍSTICAS QUE TU COLEGA OBTENDRÁ

- ✅ **API completamente funcional** con JWT y Swagger
- ✅ **Documentación completa** con ejemplos
- ✅ **Scripts de automatización** para desarrollo
- ✅ **Diagramas de arquitectura** detallados
- ✅ **Configuraciones por entorno** (dev/prod)
- ✅ **Backup de base de datos** para testing

## 🚨 NOTAS IMPORTANTES

1. **No subas el directorio `backup_`** - está excluido por .gitignore
2. **Las configuraciones sensibles** están protegidas
3. **El backup local queda en tu máquina** para restauraciones futuras
4. **Tu colega podrá contribuir** una vez invitado al repositorio

## 📞 SOPORTE

Si tienes problemas:
1. Verifica que Git esté instalado: `git --version`
2. Confirma que estés en el directorio correcto
3. Revisa que no haya errores en el commit
4. Verifica tu conexión a GitHub

---
**Proyecto:** API Recetas del Mundo v1.0.0
**Fecha:** Septiembre 2025
**Estado:** Listo para GitHub 🚀
