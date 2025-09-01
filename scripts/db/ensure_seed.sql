-- Idempotent seed for ms-recetas database
-- Inserts placeholder user, country and a sample recipe only if they do not exist

DO $$
BEGIN
  -- Ensure user id 2 exists
  IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usr = 2) THEN
    INSERT INTO usuario(id_usr, nombre, apellido, "user", password, activo)
    VALUES (2, 'Placeholder', 'Usuario', 'placeholder', 'changeme', 1);
  END IF;

  -- Ensure a sample category id 8 exists
  IF NOT EXISTS (SELECT 1 FROM categoria WHERE id_cat = 8) THEN
    INSERT INTO categoria(id_cat,nombre,estado,fecha_creacion,Comentario,imagen,id_usr)
    VALUES (8,'Desconocido 8',1,now(),'Autocreated placeholder','',2);
  END IF;

  -- Ensure a sample country id 1 exists
  IF NOT EXISTS (SELECT 1 FROM pais WHERE id_pais = 1) THEN
    INSERT INTO pais(id_pais,nombre,url_imagen,estado,fecha_creacion,Comentario,id_usr)
    VALUES (1,'País de prueba','',1,now(),NULL,2);
  END IF;

  -- Ensure a sample recipe id 1 exists
  IF NOT EXISTS (SELECT 1 FROM receta WHERE id_receta = 1) THEN
    INSERT INTO receta(id_receta,nombre,url_imagen,ingrediente,preparacion,estado,id_cat,id_pais,fecha_creacion,id_usr)
    VALUES (1,'Receta de prueba','', 'Ingrediente A;Ingrediente B', 'Paso 1;Paso 2',1, 8, 1, now(), 2);
  END IF;
END$$;
