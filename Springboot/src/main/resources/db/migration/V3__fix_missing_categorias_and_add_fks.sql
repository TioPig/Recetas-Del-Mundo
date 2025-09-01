-- V3: Insert missing categoria rows referenced by receta and add FK constraints
BEGIN;

-- Insert placeholder categories for ids referenced by receta but missing in categoria
DO $$
DECLARE
    ids int[] := ARRAY[8,10,11,12,13,14,15];
    i int;
BEGIN
    FOREACH i IN ARRAY ids LOOP
        IF NOT EXISTS (SELECT 1 FROM categoria WHERE id_cat = i) THEN
            INSERT INTO categoria(id_cat,nombre,estado,fecha_creacion,comentario,imagen,id_usr)
            VALUES (i, 'Desconocido ' || i, 1, now(), 'Placeholder auto-created to satisfy FK', '', 2);
        END IF;
    END LOOP;
END$$;

-- Ensure categoria sequence is at or above max(id_cat)
SELECT setval(pg_get_serial_sequence('categoria','id_cat'), GREATEST((SELECT COALESCE(MAX(id_cat),0) FROM categoria), (SELECT nextval(pg_get_serial_sequence('categoria','id_cat')))), false);

-- Add foreign keys now that missing categories exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_receta_categoria') THEN
        ALTER TABLE receta ADD CONSTRAINT fk_receta_categoria FOREIGN KEY (id_cat) REFERENCES categoria(id_cat) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_receta_pais') THEN
        ALTER TABLE receta ADD CONSTRAINT fk_receta_pais FOREIGN KEY (id_pais) REFERENCES pais(id_pais) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_receta_usuario') THEN
        ALTER TABLE receta ADD CONSTRAINT fk_receta_usuario FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_categoria_usuario') THEN
        ALTER TABLE categoria ADD CONSTRAINT fk_categoria_usuario FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_pais_usuario') THEN
        ALTER TABLE pais ADD CONSTRAINT fk_pais_usuario FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE RESTRICT;
    END IF;
END$$;

-- Indexes on FK columns
CREATE INDEX IF NOT EXISTS idx_receta_id_cat ON receta(id_cat);
CREATE INDEX IF NOT EXISTS idx_receta_id_pais ON receta(id_pais);
CREATE INDEX IF NOT EXISTS idx_receta_id_usr ON receta(id_usr);

COMMIT;
