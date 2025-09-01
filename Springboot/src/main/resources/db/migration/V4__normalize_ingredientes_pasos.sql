-- V4: Create normalized tables for receta ingredients and steps and populate them
BEGIN;

-- 1) Create tables
CREATE TABLE IF NOT EXISTS receta_ingrediente (
  id_receta integer NOT NULL,
  orden integer NOT NULL,
  descripcion text NOT NULL,
  PRIMARY KEY (id_receta, orden)
);

CREATE TABLE IF NOT EXISTS receta_paso (
  id_paso serial PRIMARY KEY,
  id_receta integer NOT NULL,
  orden integer NOT NULL,
  descripcion text NOT NULL
);

-- Foreign keys
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_ingrediente_receta') THEN
    ALTER TABLE receta_ingrediente ADD CONSTRAINT fk_ingrediente_receta FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_paso_receta') THEN
    ALTER TABLE receta_paso ADD CONSTRAINT fk_paso_receta FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE;
  END IF;
END$$;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_receta_ingrediente_id_receta ON receta_ingrediente(id_receta);
CREATE INDEX IF NOT EXISTS idx_receta_paso_id_receta ON receta_paso(id_receta);

-- 2) Populate receta_ingrediente from receta.ingrediente splitting by newline (if not already populated)
DO $$
BEGIN
  IF (SELECT count(*) FROM receta_ingrediente) = 0 THEN
    INSERT INTO receta_ingrediente (id_receta, orden, descripcion)
    SELECT r.id_receta, s.ordinality, trim(s.val)
    FROM receta r,
         unnest(string_to_array(COALESCE(r.ingrediente,''), E'\n')) WITH ORDINALITY AS s(val, ordinality)
    WHERE trim(s.val) <> '';
  END IF;
END$$;

-- 3) Populate receta_paso from receta.preparacion splitting by newline (if not already populated)
DO $$
BEGIN
  IF (SELECT count(*) FROM receta_paso) = 0 THEN
    INSERT INTO receta_paso (id_receta, orden, descripcion)
    SELECT r.id_receta, s.ordinality, trim(s.val)
    FROM receta r,
         unnest(string_to_array(COALESCE(r.preparacion,''), E'\n')) WITH ORDINALITY AS s(val, ordinality)
    WHERE trim(s.val) <> '';
  END IF;
END$$;

COMMIT;
