@echo off
echo ========================================
echo    SUBIR A REPOSITORIO DE COLEGA
echo    API RECETAS DEL MUNDO
echo ========================================
echo.

if "%1"=="" (
    echo [ERROR] Debes proporcionar la URL del repositorio de tu colega
    echo.
    echo Uso: %0 https://github.com/COLEGA/repositorio.git
    echo.
    echo Ejemplo: %0 https://github.com/juanperez/api-recetas.git
    goto :end
)

set REPO_URL=%1
set CURRENT_DIR=%~dp0
set TEMP_REPO=%CURRENT_DIR%temp_repo_colega

echo [INFO] URL del repositorio: %REPO_URL%
echo [INFO] Directorio actual: %CURRENT_DIR%
echo [INFO] Directorio temporal: %TEMP_REPO%
echo.

echo [INFO] Verificando Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git no esta instalado
    echo [INFO] Instala Git desde: https://git-scm.com/downloads
    goto :end
)

echo [SUCCESS] Git esta disponible
echo.

echo [INFO] Creando directorio temporal...
if exist "%TEMP_REPO%" (
    echo [WARNING] Eliminando directorio temporal existente...
    rmdir /S /Q "%TEMP_REPO%"
)
mkdir "%TEMP_REPO%"

echo.
echo [INFO] Clonando repositorio de tu colega...
cd "%TEMP_REPO%"
git clone %REPO_URL% .
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo clonar el repositorio
    echo [INFO] Verifica que la URL sea correcta y tengas permisos
    cd "%CURRENT_DIR%"
    goto :end
)

echo.
echo [SUCCESS] Repositorio clonado exitosamente
echo.

echo [INFO] Copiando archivos de tu proyecto...
cd "%CURRENT_DIR%"

echo Copiando Springboot...
xcopy /E /I /H /Y "Springboot" "%TEMP_REPO%\Springboot\" >nul 2>&1

echo Copiando archivos de documentacion...
xcopy /Y "*.md" "%TEMP_REPO%\" >nul 2>&1
xcopy /Y "*.txt" "%TEMP_REPO%\" >nul 2>&1
xcopy /Y "*.puml" "%TEMP_REPO%\" >nul 2>&1

echo Copiando scripts...
xcopy /Y "*.bat" "%TEMP_REPO%\" >nul 2>&1
xcopy /Y "*.sh" "%TEMP_REPO%\" >nul 2>&1

echo Copiando configuracion...
copy ".gitignore" "%TEMP_REPO%\" >nul 2>&1

echo.
echo [SUCCESS] Archivos copiados
echo.

echo [INFO] Preparando commit...
cd "%TEMP_REPO%"

echo Verificando cambios...
git status

echo.
echo Agregando archivos...
git add .

echo.
echo Creando commit...
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

if %errorlevel% neq 0 (
    echo [WARNING] No hay cambios para commitear o ya esta commiteado
)

echo.
echo [INFO] Subiendo cambios...
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo    ¡SUBIDA EXITOSA!
    echo ========================================
    echo.
    echo [SUCCESS] Tu proyecto ha sido subido al repositorio de tu colega
    echo [INFO] URL: %REPO_URL%
    echo.
    echo Dile a tu colega que puede hacer:
    echo   git pull origin main
    echo.
    echo Para revisar en GitHub:
    echo   %REPO_URL%
) else (
    echo.
    echo [ERROR] Error al subir los cambios
    echo [INFO] Posibles causas:
    echo   - No tienes permisos de escritura
    echo   - Hay conflictos con archivos existentes
    echo   - Problemas de red
    echo.
    echo [INFO] Intenta hacer push manualmente:
    echo   cd %TEMP_REPO%
    echo   git push origin main
)

echo.
echo [INFO] Limpiando directorio temporal...
cd "%CURRENT_DIR%"
rmdir /S /Q "%TEMP_REPO%"

:end
echo.
echo ========================================
echo    PROCESO FINALIZADO
echo ========================================
