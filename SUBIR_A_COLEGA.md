# 🚀 SUBIR PROYECTO AL REPOSITORIO DE TU COLEGA

## 📋 INSTRUCCIONES PARA SUBIR AL REPOSITORIO DE TU COLEGA

### **MÉTODO RÁPIDO: Script Automatizado (Recomendado)**

```bash
# Windows
.\subir_a_colega.bat https://github.com/NOMBRE_COLEGA/api-recetas-del-mundo.git

# Linux/Mac
./subir_a_colega.sh https://github.com/NOMBRE_COLEGA/api-recetas-del-mundo.git
```

**¡Eso es todo!** El script hace todo automáticamente:
- ✅ Clona el repositorio de tu colega
- ✅ Copia todos tus archivos
- ✅ Crea el commit
- ✅ Sube los cambios
- ✅ Limpia archivos temporales

### **MÉTODO MANUAL: Paso a Paso**

Si prefieres hacerlo manualmente o el script tiene problemas:

#### **Paso 1: Obtener la URL del repositorio de tu colega**
Pídele a tu colega la URL de su repositorio. Debería ser algo como:
```
https://github.com/NOMBRE_COLEGA/api-recetas-del-mundo.git
```

#### **Paso 2: Clonar el repositorio de tu colega**
```bash
# Crear un directorio temporal para el repositorio de tu colega
cd C:\GitHub
git clone https://github.com/NOMBRE_COLEGA/api-recetas-del-mundo.git api-colega

# Entrar al directorio
cd api-colega
```

#### **Paso 3: Copiar tu proyecto al repositorio clonado**
```bash
# Desde el directorio de tu proyecto
cd C:\GitHub\api-recetas_del_mundo

# Copiar todo el contenido (excepto .git y backup_)
xcopy /E /I /H /Y "Springboot" "..\api-colega\Springboot\"
xcopy /Y "*.md" "..\api-colega\"
xcopy /Y "*.bat" "..\api-colega\"
xcopy /Y "*.sh" "..\api-colega\"
xcopy /Y "*.txt" "..\api-colega\"
xcopy /Y "*.puml" "..\api-colega\"
copy ".gitignore" "..\api-colega\"
```

#### **Paso 4: Preparar y subir los cambios**
```bash
# Ir al repositorio de tu colega
cd C:\GitHub\api-colega

# Ver el estado
git status

# Agregar todos los archivos
git add .

# Crear commit
git commit -m "feat: Agregar API Recetas del Mundo completa

✅ Características implementadas:
- Perfiles de desarrollo y producción
- Autenticación JWT completa
- Documentación Swagger/OpenAPI
- Paginación automática
- Base de datos PostgreSQL + MongoDB
- Diagramas de base de datos completos
- Scripts de automatización

📦 Contenido agregado:
- Backend Spring Boot completo
- Configuraciones por perfil
- Scripts de inicio (Windows/Linux)
- Documentación completa
- Diagramas de base de datos
- Backup de base de datos incluido

🔧 Configuración lista para desarrollo"

# Subir los cambios
git push origin main
```

## 🔄 **MÉTODO ALTERNATIVO: Usar tu repositorio como base**

Si prefieres usar tu repositorio como base:

```bash
# En tu repositorio local
cd C:\GitHub\api-recetas_del_mundo

# Cambiar el remote al repositorio de tu colega
git remote set-url origin https://github.com/NOMBRE_COLEGA/api-recetas-del-mundo.git

# Subir los cambios
git push origin main
```

## ⚠️ **IMPORTANTE: Verificar permisos**

Antes de subir, asegúrate de que:
1. Tu colega te haya dado permisos de **write** en su repositorio
2. El repositorio de tu colega esté vacío o puedas hacer merge
3. No haya conflictos de archivos

## 📞 **Si hay conflictos o problemas**

Si hay archivos que ya existen en el repositorio de tu colega:

```bash
# Ver qué archivos tienen conflictos
git status

# Para archivos específicos que quieres sobrescribir
git add -A
git commit --amend --no-edit
git push --force-with-lease origin main
```

## 🎯 **VERIFICACIÓN FINAL**

Después de subir, verifica que todo esté correcto:

```bash
# Ver el historial de commits
git log --oneline

# Ver que los archivos estén en GitHub
# Ve a https://github.com/NOMBRE_COLEGA/api-recetas-del-mundo
```

## 📱 **Informar a tu colega**

Una vez subido, dile a tu colega que puede:
1. Hacer `git pull` para obtener los cambios
2. Revisar la documentación en `README.md`
3. Usar los scripts de inicio: `start.bat` o `./start.sh`

## 📋 **ARCHIVOS CREADOS PARA ESTE PROCESO**

- **`subir_a_colega.bat`** - Script automatizado para Windows
- **`subir_a_colega.sh`** - Script automatizado para Linux/Mac
- **`SUBIR_A_COLEGA.md`** - Instrucciones detalladas

---
**¿Tienes la URL del repositorio de tu colega para ejecutar el script automáticamente?**
