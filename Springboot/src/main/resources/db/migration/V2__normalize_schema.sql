-- Flyway migration V2: Normalize schema and add constraints/indexes
BEGIN;

-- 1) Ensure 'comentario' columns are text (pais had integer in earlier dump)
ALTER TABLE IF EXISTS pais ALTER COLUMN comentario TYPE text USING comentario::text;

-- 2) Make receta.fecha_creacion a timestamp for consistency with other tables
-- If a view depends on this column, DROP it first to allow ALTER.
DROP VIEW IF EXISTS receta_full CASCADE;
ALTER TABLE IF EXISTS receta ALTER COLUMN fecha_creacion TYPE timestamp USING fecha_creacion::timestamp;

-- 3) Set sensible defaults for estado/activo where appropriate
ALTER TABLE IF EXISTS categoria ALTER COLUMN estado SET DEFAULT 1;
ALTER TABLE IF EXISTS pais ALTER COLUMN estado SET DEFAULT 1;
ALTER TABLE IF EXISTS receta ALTER COLUMN estado SET DEFAULT 1;
ALTER TABLE IF EXISTS usuario ALTER COLUMN activo SET DEFAULT 1;

-- 4) Add foreign key constraints if they don't exist (safe checks)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_receta_categoria') THEN
        ALTER TABLE receta ADD CONSTRAINT fk_receta_categoria FOREIGN KEY (id_cat) REFERENCES categoria(id_cat) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_receta_pais') THEN
        ALTER TABLE receta ADD CONSTRAINT fk_receta_pais FOREIGN KEY (id_pais) REFERENCES pais(id_pais) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_receta_usuario') THEN
        ALTER TABLE receta ADD CONSTRAINT fk_receta_usuario FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_categoria_usuario') THEN
        ALTER TABLE categoria ADD CONSTRAINT fk_categoria_usuario FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_pais_usuario') THEN
        ALTER TABLE pais ADD CONSTRAINT fk_pais_usuario FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE SET NULL;
    END IF;
END$$;

-- 5) Indexes on foreign key columns for performance
CREATE INDEX IF NOT EXISTS idx_receta_id_cat ON receta(id_cat);
CREATE INDEX IF NOT EXISTS idx_receta_id_pais ON receta(id_pais);
CREATE INDEX IF NOT EXISTS idx_receta_id_usr ON receta(id_usr);

COMMIT;
