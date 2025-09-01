#!/bin/bash

echo "========================================"
echo "   API RECETAS DEL MUNDO - INICIO RAPIDO"
echo "========================================"
echo

if [ "$1" = "dev" ]; then
    echo "[INFO] Iniciando servidor en modo DESARROLLO..."
    echo "[INFO] Perfil: dev"
    echo "[INFO] Puerto: 8081"
    echo "[INFO] Base de datos: PostgreSQL local"
    echo "[INFO] Swagger UI: http://localhost:8081/swagger-ui.html"
    echo
    mvn spring-boot:run -Dspring-boot.run.profiles=dev

elif [ "$1" = "prod" ]; then
    echo "[INFO] Iniciando servidor en modo PRODUCCION..."
    echo "[INFO] Perfil: prod"
    echo "[INFO] Puerto: 8080"
    echo "[INFO] Asegurate de configurar las variables de entorno"
    echo
    mvn spring-boot:run -Dspring-boot.run.profiles=prod

elif [ "$1" = "build" ]; then
    echo "[INFO] Compilando proyecto..."
    echo "[INFO] Saltando tests para compilacion rapida"
    echo
    mvn clean compile package -DskipTests
    echo
    echo "[INFO] JAR generado: target/ms-recetas-0.0.1-SNAPSHOT.jar"
    echo "[INFO] Para ejecutar: java -jar target/ms-recetas-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev"

elif [ "$1" = "clean" ]; then
    echo "[INFO] Limpiando y compilando proyecto..."
    echo
    mvn clean compile
    echo
    echo "[INFO] Proyecto limpiado y compilado exitosamente"

else
    echo "Uso: $0 [dev|prod|build|clean]"
    echo
    echo "Comandos disponibles:"
    echo "  dev   - Ejecutar en modo desarrollo"
    echo "  prod  - Ejecutar en modo produccion"
    echo "  build - Compilar proyecto"
    echo "  clean - Limpiar y compilar"
    echo
    echo "Si no se especifica comando, se ejecuta en modo desarrollo"
    echo
    echo "[INFO] Iniciando servidor en modo DESARROLLO..."
    echo "[INFO] Perfil: dev"
    echo "[INFO] Puerto: 8081"
    echo "[INFO] Base de datos: PostgreSQL local"
    echo "[INFO] Swagger UI: http://localhost:8081/swagger-ui.html"
    echo
    mvn spring-boot:run -Dspring-boot.run.profiles=dev
fi

echo
echo "========================================"
echo "    PROCESO FINALIZADO"
echo "========================================"
