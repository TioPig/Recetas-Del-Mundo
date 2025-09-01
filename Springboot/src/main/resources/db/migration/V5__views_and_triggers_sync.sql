-- V5: Create view `receta_full` and triggers to sync normalized tables on receta INSERT/UPDATE
BEGIN;

-- 1) Create view that exposes receta with ingredients and pasos as arrays
CREATE OR REPLACE VIEW receta_full AS
SELECT r.*, 
       (SELECT array_agg(ri.descripcion ORDER BY ri.orden) FROM receta_ingrediente ri WHERE ri.id_receta = r.id_receta) AS ingredientes,
       (SELECT array_agg(rp.descripcion ORDER BY rp.orden) FROM receta_paso rp WHERE rp.id_receta = r.id_receta) AS pasos
FROM receta r;

-- 2) Function to repopulate receta_ingrediente from receta.ingrediente (newline separated)
CREATE OR REPLACE FUNCTION sync_receta_to_normalized() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  -- delete existing normalized rows for this receta
  DELETE FROM receta_ingrediente WHERE id_receta = NEW.id_receta;
  DELETE FROM receta_paso WHERE id_receta = NEW.id_receta;

  -- insert ingredientes from legacy column
  INSERT INTO receta_ingrediente (id_receta, orden, descripcion)
  SELECT NEW.id_receta, s.ordinality, trim(s.val)
  FROM unnest(string_to_array(COALESCE(NEW.ingrediente,''), E'\n')) WITH ORDINALITY AS s(val, ordinality)
  WHERE trim(s.val) <> '';

  -- insert pasos from legacy preparacion
  INSERT INTO receta_paso (id_receta, orden, descripcion)
  SELECT NEW.id_receta, s.ordinality, trim(s.val)
  FROM unnest(string_to_array(COALESCE(NEW.preparacion,''), E'\n')) WITH ORDINALITY AS s(val, ordinality)
  WHERE trim(s.val) <> '';

  RETURN NEW;
END;
$$;

-- 3) Trigger to call function on INSERT OR UPDATE
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_sync_receta_normalized') THEN
    CREATE TRIGGER trg_sync_receta_normalized
    AFTER INSERT OR UPDATE ON receta
    FOR EACH ROW EXECUTE FUNCTION sync_receta_to_normalized();
  END IF;
END$$;

COMMIT;
