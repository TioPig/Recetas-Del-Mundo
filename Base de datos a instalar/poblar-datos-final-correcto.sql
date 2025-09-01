-- Script SQL para poblar base de datos PostgreSQL - Recetas Latinoamericanas
-- INSERT de datos con IDs de usuario correctos

-- Insertar categorías (usando id_usr = 4 que es el Admin)
INSERT INTO categoria (nombre, estado, fecha_creacion, imagen, id_usr) VALUES
('Ceviches y Mariscos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/seafood.png', 4),
('Carnes Asadas', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/beef.png', 4),
('Arroces y Guarniciones', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/side.png', 4),
('Postres Tradicionales', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/dessert.png', 4),
('Sopas y Caldos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/starter.png', 4),
('Antojitos y Aperitivos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/starter.png', 4),
('Platos Típicos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/miscellaneous.png', 4),
('Ensaladas Frescas', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/vegetarian.png', 4),
('Bebidas Tradicionales', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/miscellaneous.png', 4),
('Platos Vegetarianos', 1, CURRENT_TIMESTAMP, 'https://www.themealdb.com/images/category/vegetarian.png', 4);

-- Insertar países (usando id_usr = 4)
INSERT INTO pais (nombre, url_imagen, estado, fecha_creacion, id_usr) VALUES
('Chile', 'https://flagcdn.com/w320/cl.png', 1, CURRENT_TIMESTAMP, 4),
('Perú', 'https://flagcdn.com/w320/pe.png', 1, CURRENT_TIMESTAMP, 4),
('Argentina', 'https://flagcdn.com/w320/ar.png', 1, CURRENT_TIMESTAMP, 4),
('Bolivia', 'https://flagcdn.com/w320/bo.png', 1, CURRENT_TIMESTAMP, 4),
('Colombia', 'https://flagcdn.com/w320/co.png', 1, CURRENT_TIMESTAMP, 4),
('Brasil', 'https://flagcdn.com/w320/br.png', 1, CURRENT_TIMESTAMP, 4),
('Ecuador', 'https://flagcdn.com/w320/ec.png', 1, CURRENT_TIMESTAMP, 4),
('Paraguay', 'https://flagcdn.com/w320/py.png', 1, CURRENT_TIMESTAMP, 4);

-- Insertar algunas recetas de ejemplo
INSERT INTO receta (nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr)
SELECT 'Ceviche Peruano Clásico', 'https://www.themealdb.com/images/media/meals/xxrxux1503070723.jpg',
'500g de corvina fresca; 8 limones; 1 cebolla roja; 1 ají limo; Cilantro fresco; Sal al gusto; 2 dientes de ajo',
'Cortar el pescado en cubos pequeños. Exprimir los limones y marinar el pescado por 15-20 minutos. Agregar cebolla en juliana, ají picado, ajo machacado y cilantro. Revolver bien y dejar reposar 5 minutos más. Servir frío con cancha serrana.',
1, c.id_cat, p.id_pais, CURRENT_TIMESTAMP, 4
FROM categoria c, pais p
WHERE c.nombre = 'Ceviches y Mariscos' AND p.nombre = 'Perú';

INSERT INTO receta (nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr)
SELECT 'Asado Argentino con Chimichurri', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg',
'1kg de costillas de res; Sal gruesa; Pimienta negra; Chimichurri (perejil, ajo, aceite, vinagre, orégano); Achuras variadas',
'Sazonar la carne con sal y pimienta. Preparar chimichurri mezclando todos los ingredientes. Asar las costillas a fuego medio por 2 horas. Servir con chimichurri y achuras asadas. Acompañar con vino tinto.',
1, c.id_cat, p.id_pais, CURRENT_TIMESTAMP, 4
FROM categoria c, pais p
WHERE c.nombre = 'Carnes Asadas' AND p.nombre = 'Argentina';

INSERT INTO receta (nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr)
SELECT 'Feijoada Brasileña', 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg',
'1kg de frijoles negros; 500g de carne seca; 300g de costillas; 200g de chorizo; Arroz blanco; Farofa; Naranja',
'Cocinar frijoles con carnes por 3 horas. Preparar farofa con harina de mandioca. Servir con arroz, farofa y rodajas de naranja. Plato nacional de Brasil.',
1, c.id_cat, p.id_pais, CURRENT_TIMESTAMP, 4
FROM categoria c, pais p
WHERE c.nombre = 'Platos Típicos' AND p.nombre = 'Brasil';
