CREATE OR REPLACE FUNCTION public.sync_receta_to_normalized()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- delete existing normalized rows for this receta
  DELETE FROM receta_ingrediente WHERE id_receta = NEW.id_receta;
  DELETE FROM receta_paso WHERE id_receta = NEW.id_receta;

  -- insert ingredientes from legacy column using ';'
  INSERT INTO receta_ingrediente (id_receta, orden, descripcion)
    SELECT NEW.id_receta, s.ordinality, trim(s.val)
    FROM unnest(string_to_array(COALESCE(NEW.ingrediente,''), ';')) WITH ORDINALITY AS s(val, ordinality)
    WHERE trim(s.val) <> '';

  -- insert pasos from legacy preparacion using ';'
  INSERT INTO receta_paso (id_receta, orden, descripcion)
    SELECT NEW.id_receta, s.ordinality, trim(s.val)
    FROM unnest(string_to_array(COALESCE(NEW.preparacion,''), ';')) WITH ORDINALITY AS s(val, ordinality)
    WHERE trim(s.val) <> '';

  RETURN NEW;
END;
$$;
