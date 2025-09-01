-- V7: Create notify trigger and function for engagement changes
CREATE OR REPLACE FUNCTION notify_receta_changes() RETURNS trigger AS $$
BEGIN
  PERFORM pg_notify('receta_changes', TG_OP || ':' || COALESCE(NEW.id_receta::text, OLD.id_receta::text));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers to the engagement tables
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_notify_comentario') THEN
    CREATE TRIGGER trg_notify_comentario
    AFTER INSERT OR UPDATE ON receta_comentario
    FOR EACH ROW EXECUTE FUNCTION notify_receta_changes();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_notify_valoracion') THEN
    CREATE TRIGGER trg_notify_valoracion
    AFTER INSERT OR UPDATE ON receta_valoracion
    FOR EACH ROW EXECUTE FUNCTION notify_receta_changes();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_notify_like') THEN
    CREATE TRIGGER trg_notify_like
    AFTER INSERT OR UPDATE ON receta_like
    FOR EACH ROW EXECUTE FUNCTION notify_receta_changes();
  END IF;
END$$;
