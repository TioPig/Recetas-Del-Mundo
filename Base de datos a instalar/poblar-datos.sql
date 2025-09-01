-- Script SQL para poblar base de datos PostgreSQL - Recetas Latinoamericanas
-- Solo INSERT de datos (tablas ya existen)

-- Insertar usuarios primero (sin columna email)
INSERT INTO usuario (id_usr, nombre, apellido, password, estado, fecha_creacion, id_pais) VALUES
(1, 'Admin', 'Sistema', '$2a$10$encryptedpassword', 1, '2025-08-30 17:50:00', NULL),
(2, 'Chef', 'Latino', '$2a$10$encryptedpassword', 1, '2025-08-30 17:50:00', NULL),
(3, 'Usuario', 'Prueba', '$2a$10$encryptedpassword', 1, '2025-08-30 17:50:00', NULL);

-- Insertar categorías
INSERT INTO categoria (id_cat, nombre, estado, fecha_creacion, comentario, imagen, id_usr) VALUES
(1, 'Ceviches y Mariscos', 1, '2025-08-30 17:50:00', 'Especialidades de mariscos frescos marinados en limón, típicos de la costa latinoamericana', 'https://www.themealdb.com/images/category/seafood.png', 1),
(2, 'Carnes Asadas', 1, '2025-08-30 17:50:00', 'Carnes a la parrilla con condimentos tradicionales latinoamericanos', 'https://www.themealdb.com/images/category/beef.png', 1),
(3, 'Arroces y Guarniciones', 1, '2025-08-30 17:50:00', 'Arroces, frijoles y acompañamientos que complementan los platos principales', 'https://www.themealdb.com/images/category/side.png', 1),
(4, 'Postres Tradicionales', 1, '2025-08-30 17:50:00', 'Dulces y postres típicos de la gastronomía latinoamericana', 'https://www.themealdb.com/images/category/dessert.png', 1),
(5, 'Sopas y Caldos', 1, '2025-08-30 17:50:00', 'Sopas, caldos y cremas tradicionales de América Latina', 'https://www.themealdb.com/images/category/starter.png', 1),
(6, 'Antojitos y Aperitivos', 1, '2025-08-30 17:50:00', 'Tapas, bocadillos y entradas ligeras típicas de la región', 'https://www.themealdb.com/images/category/starter.png', 1),
(7, 'Platos Típicos', 1, '2025-08-30 17:50:00', 'Platos emblemáticos y representativos de cada país latinoamericano', 'https://www.themealdb.com/images/category/miscellaneous.png', 1),
(8, 'Ensaladas Frescas', 1, '2025-08-30 17:50:00', 'Ensaladas con ingredientes frescos y aderezos tradicionales', 'https://www.themealdb.com/images/category/vegetarian.png', 1),
(9, 'Bebidas Tradicionales', 1, '2025-08-30 17:50:00', 'Refrescos, jugos y bebidas típicas de América Latina', 'https://www.themealdb.com/images/category/miscellaneous.png', 1),
(10, 'Platos Vegetarianos', 1, '2025-08-30 17:50:00', 'Recetas vegetarianas con ingredientes locales latinoamericanos', 'https://www.themealdb.com/images/category/vegetarian.png', 1);

-- Insertar países
INSERT INTO pais (id_pais, nombre, url_imagen, estado, fecha_creacion, comentario, id_usr) VALUES
(1, 'Chile', 'https://flagcdn.com/w320/cl.png', 1, '2025-08-30 17:50:00', NULL, 1),
(2, 'Perú', 'https://flagcdn.com/w320/pe.png', 1, '2025-08-30 17:50:00', NULL, 1),
(3, 'Argentina', 'https://flagcdn.com/w320/ar.png', 1, '2025-08-30 17:50:00', NULL, 1),
(4, 'Bolivia', 'https://flagcdn.com/w320/bo.png', 1, '2025-08-30 17:50:00', NULL, 1),
(5, 'Colombia', 'https://flagcdn.com/w320/co.png', 1, '2025-08-30 17:50:00', NULL, 1),
(6, 'Brasil', 'https://flagcdn.com/w320/br.png', 1, '2025-08-30 17:50:00', NULL, 1),
(7, 'Ecuador', 'https://flagcdn.com/w320/ec.png', 1, '2025-08-30 17:50:00', NULL, 1),
(8, 'Paraguay', 'https://flagcdn.com/w320/py.png', 1, '2025-08-30 17:50:00', NULL, 1);

-- Insertar recetas (solo las primeras 10 para probar)
INSERT INTO receta (id_receta, nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr) VALUES
(1, 'Ceviche Peruano Clásico', 'https://www.themealdb.com/images/media/meals/xxrxux1503070723.jpg', '500g de corvina fresca; 8 limones; 1 cebolla roja; 1 ají limo; Cilantro fresco; Sal al gusto; 2 dientes de ajo', 'Cortar el pescado en cubos pequeños. Exprimir los limones y marinar el pescado por 15-20 minutos. Agregar cebolla en juliana, ají picado, ajo machacado y cilantro. Revolver bien y dejar reposar 5 minutos más. Servir frío con cancha serrana.', 1, 1, 2, '2025-08-30', 1),
(2, 'Ceviche Chileno de Ostras', 'https://www.themealdb.com/images/media/meals/wqqvyq1511179730.jpg', '12 ostras frescas; 6 limones; 1 cebolla morada; 1 ají verde; Perejil fresco; Aceite de oliva; Sal marina', 'Abrir las ostras y separar la carne. Exprimir los limones sobre las ostras. Agregar cebolla en juliana fina, ají picado y perejil. Aliñar con aceite de oliva y sal. Dejar marinar 10 minutos. Servir con pan amasado.', 1, 1, 1, '2025-08-30', 1),
(3, 'Tiradito Nikkei Peruano', 'https://www.themealdb.com/images/media/meals/xxrxux1503070723.jpg', '400g de sashimi de atún; 4 limones; 2 ajíes amarillos; Jengibre fresco; Aceite de sésamo; Salsa de soya; Cebollín', 'Cortar el atún en láminas finas. Preparar la salsa con limones, ají amarillo, jengibre y aceite de sésamo. Bañar el atún con la salsa. Decorar con cebollín picado. Servir inmediatamente con chips de camote.', 1, 1, 2, '2025-08-30', 1),
(4, 'Ceviche Ecuatoriano de Camarón', 'https://www.themealdb.com/images/media/meals/uvuyxu1503067369.jpg', '500g de camarones; 6 limones; 1 cebolla blanca; 1 tomate; Cilantro; Ají picante; Maíz tostado', 'Cocinar los camarones 2 minutos en agua con sal. Enfriar y pelar. Marinar con jugo de limón por 10 minutos. Agregar cebolla, tomate y cilantro picados. Sazonar con ají. Servir con maíz tostado y patacones.', 1, 1, 7, '2025-08-30', 1),
(5, 'Ceviche Paraguayo de Surubí', 'https://www.themealdb.com/images/media/meals/1520081754.jpg', '600g de surubí; 8 limones; 1 cebolla; 1 pimiento rojo; Perejil; Aceite; Sal; Mandioca cocida', 'Cortar el pescado en cubos. Marinar con jugo de limón por 20 minutos. Agregar cebolla y pimiento en juliana. Condimentar con perejil, aceite y sal. Servir con mandioca cocida como acompañamiento.', 1, 1, 8, '2025-08-30', 1),
(6, 'Asado Argentino con Chimichurri', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg', '1kg de costillas de res; Sal gruesa; Pimienta negra; Chimichurri (perejil, ajo, aceite, vinagre, orégano); Achuras variadas', 'Sazonar la carne con sal y pimienta. Preparar chimichurri mezclando todos los ingredientes. Asar las costillas a fuego medio por 2 horas. Servir con chimichurri y achuras asadas. Acompañar con vino tinto.', 1, 2, 3, '2025-08-30', 1),
(7, 'Churrasco Uruguayo', 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg', '800g de lomo de res; Sal; Pimienta; Chimichurri; Ensalada de repollo; Pan casero', 'Cortar el lomo en medallones gruesos. Sazonar con sal y pimienta. Asar a la parrilla 4-5 minutos por lado. Preparar chimichurri con perejil, ajo, aceite y vinagre. Servir con ensalada y pan.', 1, 2, 3, '2025-08-30', 1),
(8, 'Carne de Res a la Parrilla Colombiana', 'https://www.themealdb.com/images/media/meals/uuqvwu1504629254.jpg', '1kg de punta de anca; Sal; Comino; Ajo; Cúrcuma; Hogao (tomate, cebolla, cilantro); Arroz blanco', 'Marinar la carne con sal, comino, ajo y cúrcuma por 2 horas. Asar a la parrilla hasta el punto deseado. Preparar hogao sofriendo tomate, cebolla y cilantro. Servir la carne con hogao y arroz blanco.', 1, 2, 5, '2025-08-30', 1),
(9, 'Picanha Brasileña', 'https://www.themealdb.com/images/media/meals/atd5sh1583188467.jpg', '1.5kg de picanha; Sal gruesa; Farofa; Vinagrete; Mandioca frita', 'Sazonar la picanha con sal gruesa. Asar con la grasa hacia arriba primero. Cortar en rodajas. Preparar farofa con harina de mandioca y mantequilla. Servir con vinagrete y mandioca frita.', 1, 2, 6, '2025-08-30', 1),
(10, 'Lomo Saltado Peruano', 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg', '500g de lomo fino; 2 cebollas; 2 tomates; Cilantro; Salsa de soya; Vinagre; Papas fritas; Arroz', 'Cortar el lomo en tiras finas. Saltear en wok caliente. Agregar cebolla y tomate en juliana. Condimentar con soya y vinagre. Incorporar cilantro. Servir con papas fritas y arroz blanco.', 1, 2, 2, '2025-08-30', 1);
