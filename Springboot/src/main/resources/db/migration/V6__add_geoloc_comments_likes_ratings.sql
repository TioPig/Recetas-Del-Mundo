-- V6: Add geolocation columns to receta and transactional tables for comments, likes and ratings
BEGIN;

-- 1) Add geolocation columns to receta
ALTER TABLE IF EXISTS receta
  ADD COLUMN IF NOT EXISTS latitude double precision,
  ADD COLUMN IF NOT EXISTS longitude double precision;

-- 2) Table: receta_comentario (comments)
CREATE TABLE IF NOT EXISTS receta_comentario (
  id serial PRIMARY KEY,
  id_receta integer NOT NULL,
  id_usr integer,
  comentario text NOT NULL,
  fecha timestamp NOT NULL DEFAULT now(),
  FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
  FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_receta_comentario_receta ON receta_comentario(id_receta);

-- 3) Table: receta_valoracion (ratings)
CREATE TABLE IF NOT EXISTS receta_valoracion (
  id serial PRIMARY KEY,
  id_receta integer NOT NULL,
  id_usr integer,
  score smallint NOT NULL CHECK (score >= 1 AND score <= 5),
  fecha timestamp NOT NULL DEFAULT now(),
  FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
  FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE SET NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_receta_valoracion_receta_usr ON receta_valoracion(id_receta, id_usr);
CREATE INDEX IF NOT EXISTS idx_receta_valoracion_receta ON receta_valoracion(id_receta);

-- 4) Table: receta_like (likes as boolean per user)
CREATE TABLE IF NOT EXISTS receta_like (
  id_receta integer NOT NULL,
  id_usr integer NOT NULL,
  liked boolean NOT NULL DEFAULT true,
  fecha timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY (id_receta, id_usr),
  FOREIGN KEY (id_receta) REFERENCES receta(id_receta) ON DELETE CASCADE,
  FOREIGN KEY (id_usr) REFERENCES usuario(id_usr) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_receta_like_receta ON receta_like(id_receta);

COMMIT;
