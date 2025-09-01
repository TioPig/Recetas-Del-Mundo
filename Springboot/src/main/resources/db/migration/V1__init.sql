-- Flyway initial migration: create basic tables used by the app

CREATE TABLE IF NOT EXISTS categoria (
  id_cat serial PRIMARY KEY,
  nombre varchar(50) NOT NULL,
  estado smallint NOT NULL DEFAULT 0,
  fecha_creacion timestamp NOT NULL,
  Comentario text,
  imagen varchar(100) NOT NULL,
  id_usr integer NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS categoria_nombre_uq ON categoria(nombre);

CREATE TABLE IF NOT EXISTS pais (
  id_pais serial PRIMARY KEY,
  nombre varchar(50) NOT NULL,
  url_imagen varchar(300) NOT NULL,
  estado integer NOT NULL DEFAULT 0,
  fecha_creacion timestamp NOT NULL,
  Comentario integer,
  id_usr integer NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS pais_nombre_uq ON pais(nombre);

CREATE TABLE IF NOT EXISTS receta (
  id_receta serial PRIMARY KEY,
  nombre varchar(200) NOT NULL,
  url_imagen varchar(300) NOT NULL,
  ingrediente text NOT NULL,
  preparacion text NOT NULL,
  estado smallint NOT NULL,
  id_cat integer NOT NULL,
  id_pais integer NOT NULL,
  fecha_creacion date NOT NULL,
  id_usr integer NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS receta_nombre_uq ON receta(nombre);

CREATE TABLE IF NOT EXISTS usuario (
  id_usr serial PRIMARY KEY,
  nombre varchar(64),
  apellido varchar(64),
  "user" varchar(16),
  password varchar(64),
  activo smallint
);
