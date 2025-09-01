-- Script SQL para poblar base de datos PostgreSQL - Recetas Latinoamericanas
-- INSERT de datos basado en estructura real de las tablas

-- Insertar usuarios (con columnas correctas: nombre, apellido, user, password, activo)
INSERT INTO usuario (nombre, apellido, "user", password, activo) VALUES
('Admin', 'Sistema', 'admin', '$2a$10$encryptedpassword', 1),
('Chef', 'Latino', 'chef', '$2a$10$encryptedpassword', 1),
('Usuario', 'Prueba', 'usuario', '$2a$10$encryptedpassword', 1);

-- Insertar categorías
INSERT INTO categoria (nombre, estado, fecha_creacion, imagen, id_usr) VALUES
('Ceviches y Mariscos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/seafood.png', 1),
('Carnes Asadas', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/beef.png', 1),
('Arroces y Guarniciones', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/side.png', 1),
('Postres Tradicionales', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/dessert.png', 1),
('Sopas y Caldos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/starter.png', 1),
('Antojitos y Aperitivos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/starter.png', 1),
('Platos Típicos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/miscellaneous.png', 1),
('Ensaladas Frescas', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/vegetarian.png', 1),
('Bebidas Tradicionales', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/miscellaneous.png', 1),
('Platos Vegetarianos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/vegetarian.png', 1);

-- Insertar países
INSERT INTO pais (nombre, url_imagen, estado, fecha_creacion, id_usr) VALUES
('Chile', 'https://flagcdn.com/w320/cl.png', 1, CURRENT_TIMESTAMP, 1),
('Perú', 'https://flagcdn.com/w320/pe.png', 1, CURRENT_TIMESTAMP, 1),
('Argentina', 'https://flagcdn.com/w320/ar.png', 1, CURRENT_TIMESTAMP, 1),
('Bolivia', 'https://flagcdn.com/w320/bo.png', 1, CURRENT_TIMESTAMP, 1),
('Colombia', 'https://flagcdn.com/w320/co.png', 1, CURRENT_TIMESTAMP, 1),
('Brasil', 'https://flagcdn.com/w320/br.png', 1, CURRENT_TIMESTAMP, 1),
('Ecuador', 'https://flagcdn.com/w320/ec.png', 1, CURRENT_TIMESTAMP, 1),
('Paraguay', 'https://flagcdn.com/w320/py.png', 1, CURRENT_TIMESTAMP, 1);

-- Insertar algunas recetas de ejemplo
INSERT INTO receta (nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr)
SELECT 'Ceviche Peruano Clásico', 'https://www.themealdb.com/images/media/meals/xxrxux1503070723.jpg',
'500g de corvina fresca; 8 limones; 1 cebolla roja; 1 ají limo; Cilantro fresco; Sal al gusto; 2 dientes de ajo',
'Cortar el pescado en cubos pequeños. Exprimir los limones y marinar el pescado por 15-20 minutos. Agregar cebolla en juliana, ají picado, ajo machacado y cilantro. Revolver bien y dejar reposar 5 minutos más. Servir frío con cancha serrana.',
1, c.id_cat, p.id_pais, CURRENT_TIMESTAMP, 1
FROM categoria c, pais p
WHERE c.nombre = 'Ceviches y Mariscos' AND p.nombre = 'Perú';

INSERT INTO receta (nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr)
SELECT 'Asado Argentino con Chimichurri', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg',
'1kg de costillas de res; Sal gruesa; Pimienta negra; Chimichurri (perejil, ajo, aceite, vinagre, orégano); Achuras variadas',
'Sazonar la carne con sal y pimienta. Preparar chimichurri mezclando todos los ingredientes. Asar las costillas a fuego medio por 2 horas. Servir con chimichurri y achuras asadas. Acompañar con vino tinto.',
1, c.id_cat, p.id_pais, CURRENT_TIMESTAMP, 1
FROM categoria c, pais p
WHERE c.nombre = 'Carnes Asadas' AND p.nombre = 'Argentina';

INSERT INTO receta (nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr)
SELECT 'Feijoada Brasileña', 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg',
'1kg de frijoles negros; 500g de carne seca; 300g de costillas; 200g de chorizo; Arroz blanco; Farofa; Naranja',
'Cocinar frijoles con carnes por 3 horas. Preparar farofa con harina de mandioca. Servir con arroz, farofa y rodajas de naranja. Plato nacional de Brasil.',
1, c.id_cat, p.id_pais, CURRENT_TIMESTAMP, 1
FROM categoria c, pais p
WHERE c.nombre = 'Platos Típicos' AND p.nombre = 'Brasil';
