#!/bin/bash

echo "========================================"
echo "   SUBIR A REPOSITORIO DE COLEGA"
echo "   API RECETAS DEL MUNDO"
echo "========================================"
echo

if [ -z "$1" ]; then
    echo "[ERROR] Debes proporcionar la URL del repositorio de tu colega"
    echo
    echo "Uso: $0 https://github.com/COLEGA/repositorio.git"
    echo
    echo "Ejemplo: $0 https://github.com/juanperez/api-recetas.git"
    exit 1
fi

REPO_URL=$1
CURRENT_DIR=$(pwd)
TEMP_REPO="${CURRENT_DIR}/temp_repo_colega"

echo "[INFO] URL del repositorio: $REPO_URL"
echo "[INFO] Directorio actual: $CURRENT_DIR"
echo "[INFO] Directorio temporal: $TEMP_REPO"
echo

echo "[INFO] Verificando Git..."
if ! command -v git &> /dev/null; then
    echo "[ERROR] Git no esta instalado"
    echo "[INFO] Instala Git con: sudo apt-get install git"
    exit 1
fi

echo "[SUCCESS] Git esta disponible"
echo

echo "[INFO] Creando directorio temporal..."
if [ -d "$TEMP_REPO" ]; then
    echo "[WARNING] Eliminando directorio temporal existente..."
    rm -rf "$TEMP_REPO"
fi
mkdir "$TEMP_REPO"

echo
echo "[INFO] Clonando repositorio de tu colega..."
cd "$TEMP_REPO"
git clone "$REPO_URL" .
if [ $? -ne 0 ]; then
    echo "[ERROR] No se pudo clonar el repositorio"
    echo "[INFO] Verifica que la URL sea correcta y tengas permisos"
    cd "$CURRENT_DIR"
    exit 1
fi

echo
echo "[SUCCESS] Repositorio clonado exitosamente"
echo

echo "[INFO] Copiando archivos de tu proyecto..."
cd "$CURRENT_DIR"

echo "Copiando Springboot..."
cp -r Springboot "$TEMP_REPO/"

echo "Copiando archivos de documentacion..."
cp *.md "$TEMP_REPO/" 2>/dev/null || true
cp *.txt "$TEMP_REPO/" 2>/dev/null || true
cp *.puml "$TEMP_REPO/" 2>/dev/null || true

echo "Copiando scripts..."
cp *.bat "$TEMP_REPO/" 2>/dev/null || true
cp *.sh "$TEMP_REPO/" 2>/dev/null || true

echo "Copiando configuracion..."
cp .gitignore "$TEMP_REPO/" 2>/dev/null || true

echo
echo "[SUCCESS] Archivos copiados"
echo

echo "[INFO] Preparando commit..."
cd "$TEMP_REPO"

echo "Verificando cambios..."
git status

echo
echo "Agregando archivos..."
git add .

echo
echo "Creando commit..."
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

if [ $? -ne 0 ]; then
    echo "[WARNING] No hay cambios para commitear o ya esta commiteado"
fi

echo
echo "[INFO] Subiendo cambios..."
git push origin main

if [ $? -eq 0 ]; then
    echo
    echo "========================================"
    echo "    ¡SUBIDA EXITOSA!"
    echo "========================================"
    echo
    echo "[SUCCESS] Tu proyecto ha sido subido al repositorio de tu colega"
    echo "[INFO] URL: $REPO_URL"
    echo
    echo "Dile a tu colega que puede hacer:"
    echo "  git pull origin main"
    echo
    echo "Para revisar en GitHub:"
    echo "  $REPO_URL"
else
    echo
    echo "[ERROR] Error al subir los cambios"
    echo "[INFO] Posibles causas:"
    echo "  - No tienes permisos de escritura"
    echo "  - Hay conflictos con archivos existentes"
    echo "  - Problemas de red"
    echo
    echo "[INFO] Intenta hacer push manualmente:"
    echo "  cd $TEMP_REPO"
    echo "  git push origin main"
fi

echo
echo "[INFO] Limpiando directorio temporal..."
cd "$CURRENT_DIR"
rm -rf "$TEMP_REPO"

echo
echo "========================================"
echo "   PROCESO FINALIZADO"
echo "========================================"
