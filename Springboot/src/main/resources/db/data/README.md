Recetas - datos para importación

Contenido:
- `receta.csv`: CSV generado desde el volcado MySQL (`recetas-ejemplo.sql`).
- `convert_receta_to_csv.py`: script que extrae el bloque INSERT de `recetas-ejemplo.sql` y genera `receta.csv` (útil para regenerar).

Instrucciones rápidas para importar en el contenedor Postgres (desde la raíz del repo):

1) Copiar `receta.csv` al contenedor (reemplaza <container> por el nombre o ID):

```powershell
docker cp Springboot\src\main\resources\db\data\receta.csv <container>:/tmp/receta.csv
```

2) Importar con psql (ejecutar dentro del contenedor):

```powershell
docker exec -i <container> psql -U recetas -d recetas -c "\copy receta(id_receta,nombre,url_imagen,ingrediente,preparacion,estado,id_cat,id_pais,fecha_creacion,id_usr) FROM '/tmp/receta.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')"
```

3) Verificar conteos:

```powershell
docker exec -i <container> psql -U recetas -d recetas -c "SELECT 'receta' as tabla, count(*) FROM receta;"
```

Notas:
- El script `convert_receta_to_csv.py` busca `Base de datos a instalar/recetas-ejemplo.sql` relativo al repo; si mueves el dump, ajusta la ruta.
- Para migraciones automatizadas en producción, preferir procesos ETL controlados o cargar CSVs mediante pipelines en CI.
