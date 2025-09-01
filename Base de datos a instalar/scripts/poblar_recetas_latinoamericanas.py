#!/usr/bin/env python3
"""
Script para poblar la base de datos PostgreSQL con datos de recetas latinoamericanas
Usando psql directamente en lugar de psycopg2
"""

import subprocess
import os
from pathlib import Path

def execute_sql_with_psql(sql_file_path):
    """Ejecuta un archivo SQL usando psql"""
    try:
        # Comando psql para ejecutar el archivo SQL
        cmd = [
            'psql',
            '-h', 'localhost',
            '-p', '5432',
            '-U', 'recetas',
            '-d', 'recetas',
            '-f', str(sql_file_path)
        ]

        # Configurar variable de entorno para contraseña
        env = os.environ.copy()
        env['PGPASSWORD'] = 'recetas'

        print("📥 Ejecutando archivo SQL con psql...")
        result = subprocess.run(cmd, env=env, capture_output=True, text=True)

        if result.returncode == 0:
            print("✅ Archivo SQL ejecutado exitosamente")
            return True
        else:
            print(f"❌ Error ejecutando SQL: {result.stderr}")
            return False

    except Exception as e:
        print(f"❌ Error ejecutando psql: {e}")
        return False

def verify_data_population():
    """Verifica que los datos se hayan insertado correctamente usando psql"""
    try:
        queries = [
            ("Categorías", "SELECT COUNT(*) FROM categoria;"),
            ("Países", "SELECT COUNT(*) FROM pais;"),
            ("Recetas", "SELECT COUNT(*) FROM receta;"),
            ("Usuarios", "SELECT COUNT(*) FROM usuario;")
        ]

        print("\n� Verificando datos insertados...")

        for name, query in queries:
            cmd = [
                'psql',
                '-h', 'localhost',
                '-p', '5432',
                '-U', 'recetas',
                '-d', 'recetas',
                '-c', query,
                '-t'  # Solo resultados, sin headers
            ]

            env = os.environ.copy()
            env['PGPASSWORD'] = 'recetas'

            result = subprocess.run(cmd, env=env, capture_output=True, text=True)

            if result.returncode == 0:
                count = result.stdout.strip()
                print(f"📊 {name} insertadas: {count}")
            else:
                print(f"❌ Error consultando {name}: {result.stderr}")

        # Consulta de distribución por país
        print("\n📊 Distribución de recetas por país:")
        country_query = """
        SELECT p.nombre as pais, COUNT(r.id_receta) as total_recetas
        FROM pais p
        LEFT JOIN receta r ON p.id_pais = r.id_pais
        GROUP BY p.id_pais, p.nombre
        ORDER BY total_recetas DESC;
        """

        cmd = [
            'psql',
            '-h', 'localhost',
            '-p', '5432',
            '-U', 'recetas',
            '-d', 'recetas',
            '-c', country_query
        ]

        result = subprocess.run(cmd, env=env, capture_output=True, text=True)
        if result.returncode == 0:
            print(result.stdout)
        else:
            print(f"❌ Error en consulta de países: {result.stderr}")

    except Exception as e:
        print(f"❌ Error verificando datos: {e}")

def main():
    """Función principal"""
    print("🌎 Iniciando población de base de datos con Recetas Latinoamericanas")
    print("=" * 60)

    # Obtener ruta del archivo SQL
    script_dir = Path(__file__).resolve().parent
    sql_file = script_dir.parent / 'recetas-latinoamericanas.sql'

    if not sql_file.exists():
        print(f"❌ Archivo SQL no encontrado: {sql_file}")
        return

    print(f"📁 Archivo SQL encontrado: {sql_file}")

    # Verificar que psql esté disponible
    try:
        result = subprocess.run(['psql', '--version'], capture_output=True, text=True)
        if result.returncode != 0:
            print("❌ psql no está disponible en el sistema")
            print("💡 Asegúrate de tener PostgreSQL instalado y psql en el PATH")
            return
        print("✅ psql encontrado en el sistema")
    except Exception as e:
        print(f"❌ Error verificando psql: {e}")
        return

    try:
        # Ejecutar el archivo SQL
        success = execute_sql_with_psql(sql_file)

        if success:
            # Verificar la población de datos
            verify_data_population()
            print("\n✅ ¡Base de datos poblada exitosamente!")
            print("🎉 Ahora tienes 50 deliciosas recetas latinoamericanas")
            print("\n📋 Resumen:")
            print("  • 10 categorías temáticas")
            print("  • 8 países latinoamericanos")
            print("  • 50 recetas auténticas")
            print("  • 3 usuarios de prueba")
        else:
            print("\n❌ Falló la población de la base de datos")

    except Exception as e:
        print(f"❌ Error general: {e}")

if __name__ == "__main__":
    main()
