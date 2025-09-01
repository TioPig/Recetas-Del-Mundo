-- Script simple para poblar la BD con datos básicos

-- Insertar usuarios adicionales
INSERT INTO usuario (nombre, apellido, "user", password, activo) VALUES
('Claudio', 'Sanchez', 'claudio', '$2a$10$encrypted_password', 1);

INSERT INTO usuario (nombre, apellido, "user", password, activo) VALUES
('Juan', 'Perez', 'juan', '$2a$10$encrypted_password', 1);

-- Insertar algunas categorías usando el usuario existente (id_usr = 2)
INSERT INTO categoria (nombre, estado, fecha_creacion, imagen, id_usr) VALUES
('Desayuno', 1, CURRENT_TIMESTAMP, 'desayuno.jpg', 2);

INSERT INTO categoria (nombre, estado, fecha_creacion, imagen, id_usr) VALUES
('Pollo', 1, CURRENT_TIMESTAMP, 'pollo.jpg', 2);

INSERT INTO categoria (nombre, estado, fecha_creacion, imagen, id_usr) VALUES
('Pasta', 1, CURRENT_TIMESTAMP, 'pasta.jpg', 2);

-- Insertar algunos países usando el usuario existente
INSERT INTO pais (nombre, url_imagen, estado, fecha_creacion, id_usr) VALUES
('EEUU', 'eeuu.jpg', 1, CURRENT_TIMESTAMP, 2);

INSERT INTO pais (nombre, url_imagen, estado, fecha_creacion, id_usr) VALUES
('Italiano', 'italy.jpg', 1, CURRENT_TIMESTAMP, 2);

INSERT INTO pais (nombre, url_imagen, estado, fecha_creacion, id_usr) VALUES
('Mexicano', 'mexico.jpg', 1, CURRENT_TIMESTAMP, 2);

-- Insertar una receta de ejemplo que active el trigger
INSERT INTO receta (nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr)
SELECT 'Panqueques de Banana', 'panqueques_banana.jpg',
'2 bananas maduras machacadas;1 taza de harina;1 huevo;1 taza de leche;1 cucharadita de polvo para hornear;2 cucharadas de azúcar;1 pizca de sal;mantequilla para cocinar',
'Mezclar todos los ingredientes secos en un bowl;Agregar el huevo y la leche, mezclar hasta que quede homogéneo;Incorporar las bananas machacadas;Calentar una sartén con mantequilla;Verter la mezcla y cocinar hasta que aparezcan burbujas;Dar vuelta y cocinar el otro lado;Servir calientes',
1, c.id_cat, p.id_pais, CURRENT_TIMESTAMP, 2
FROM categoria c, pais p
WHERE c.nombre = 'Desayuno' AND p.nombre = 'EEUU';
