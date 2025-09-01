# Migraciones aplicadas

Resumen de migraciones aplicadas al esquema relacional (Postgres) para este proyecto:

- `V1__init.sql` — DDL inicial: crea tablas `categoria`, `pais`, `receta`, `usuario`.
- `V2__normalize_schema.sql` — Normalizaciones iniciales (conversión de `pais.comentario` a text, intentos de conversión de `receta.fecha_creacion` a timestamp, establecer defaults y creación de índices/constraints). Parte de V2 falló temporalmente por claves huérfanas.
- `V3__fix_missing_categorias_and_add_fks.sql` — Inserta placeholders en `categoria` para ids referenciados por `receta` que faltaban y crea finalmente las constraints FK e índices en columnas FK.

Estado actual (post V3):
- Las claves foráneas están presentes: `fk_receta_categoria`, `fk_receta_pais`, `fk_receta_usuario`, `fk_categoria_usuario`, `fk_pais_usuario`.
- Índices sobre `receta(id_cat)`, `receta(id_pais)`, `receta(id_usr)` creados.
- `pais.comentario` convertido a `text`.
- `receta.fecha_creacion` aún aparece como `varchar/character varying` en el catálogo; la entidad JPA `Receta` usa `String` para ese campo, por lo que dejarlo como está garantiza compatibilidad con los endpoints REST sin alterar código.

Decisión tomada:
- Se optó por la opción A (dejar `fecha_creacion` como string) para no modificar endpoints ni entidades. Esto mantiene la compatibilidad inmediata con el backend y evita riesgo de ruptura.

Recomendaciones (opciones futuras):
- Si deseas normalizar `fecha_creacion` a `timestamp` puedo preparar una migración segura (crear columna temporal `fecha_creacion_ts`, intentar parseo, fallback a NOW(), y mantener la columna original como respaldo). Esta operación requiere validar formatos y aceptar que algunos valores se normalicen a NOW() cuando no sean parseables.
- Revisar y reemplazar los registros placeholder en `categoria` con valores reales cuando tengas los datos.

Rollback (instrucciones rápidas)
- Para revertir V3: eliminar constraints FKs creadas y borrar filas placeholder (hacerlo con cuidado). Ejemplo (psql como superusuario o propietario):

```sql
ALTER TABLE receta DROP CONSTRAINT IF EXISTS fk_receta_categoria;
ALTER TABLE receta DROP CONSTRAINT IF EXISTS fk_receta_pais;
ALTER TABLE receta DROP CONSTRAINT IF EXISTS fk_receta_usuario;
ALTER TABLE categoria DROP CONSTRAINT IF EXISTS fk_categoria_usuario;
ALTER TABLE pais DROP CONSTRAINT IF EXISTS fk_pais_usuario;
-- Opcional: delete from categoria where nombre like 'Desconocido %';
```

- Para revertir V2 (con precaución): restaurar tipos originales y defaults si fuera necesario.

Notas de operación
- Todas las modificaciones se hicieron con migraciones Flyway ubicadas en `src/main/resources/db/migration/`.
- Mantengo los nombres de columnas y tipos en las entidades JPA para no tocar endpoints.

Si quieres que proceda con la migración de `receta.fecha_creacion` a `timestamp` (migración V4 segura), confirma y la genero y ejecuto.
