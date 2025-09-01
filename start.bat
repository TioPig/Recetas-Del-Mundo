@echo off
echo ========================================
echo    API RECETAS DEL MUNDO - INICIO RAPIDO
echo ========================================
echo.

if "%1"=="dev" goto :dev
if "%1"=="prod" goto :prod
if "%1"=="build" goto :build
if "%1"=="clean" goto :clean

echo Uso: %0 [dev^|prod^|build^|clean]
echo.
echo Comandos disponibles:
echo   dev   - Ejecutar en modo desarrollo
echo   prod  - Ejecutar en modo produccion
echo   build - Compilar proyecto
echo   clean - Limpiar y compilar
echo.
echo Si no se especifica comando, se ejecuta en modo desarrollo
echo.
goto :dev

:dev
echo [INFO] Iniciando servidor en modo DESARROLLO...
echo [INFO] Perfil: dev
echo [INFO] Puerto: 8081
echo [INFO] Base de datos: PostgreSQL local
echo [INFO] Swagger UI: http://localhost:8081/swagger-ui.html
echo.
mvn spring-boot:run -Dspring-boot.run.profiles=dev
goto :end

:prod
echo [INFO] Iniciando servidor en modo PRODUCCION...
echo [INFO] Perfil: prod
echo [INFO] Puerto: 8080
echo [INFO] Asegurate de configurar las variables de entorno
echo.
mvn spring-boot:run -Dspring-boot.run.profiles=prod
goto :end

:build
echo [INFO] Compilando proyecto...
echo [INFO] Saltando tests para compilacion rapida
echo.
mvn clean compile package -DskipTests
echo.
echo [INFO] JAR generado: target/ms-recetas-0.0.1-SNAPSHOT.jar
echo [INFO] Para ejecutar: java -jar target/ms-recetas-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
goto :end

:clean
echo [INFO] Limpiando y compilando proyecto...
echo.
mvn clean compile
echo.
echo [INFO] Proyecto limpiado y compilado exitosamente
goto :end

:end
echo.
echo ========================================
echo    PROCESO FINALIZADO
echo ========================================
