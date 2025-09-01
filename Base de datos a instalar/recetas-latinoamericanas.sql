-- phpMyAdmin SQL Dump Mejorado para Recetas Latinoamericanas
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 30-08-2025 a las 17:50:00
-- Versión del servidor: 15.0
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `recetas`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `id_cat` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `estado` tinyint(4) NOT NULL DEFAULT 0,
  `fecha_creacion` datetime NOT NULL,
  `Comentario` text DEFAULT NULL,
  `imagen` varchar(100) NOT NULL,
  `id_usr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`id_cat`, `nombre`, `estado`, `fecha_creacion`, `Comentario`, `imagen`, `id_usr`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pais`
--

CREATE TABLE `pais` (
  `id_pais` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `url_imagen` varchar(300) NOT NULL,
  `estado` int(11) NOT NULL DEFAULT 0,
  `fecha_creacion` datetime NOT NULL,
  `Comentario` int(11) DEFAULT NULL,
  `id_usr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pais`
--

INSERT INTO `pais` (`id_pais`, `nombre`, `url_imagen`, `estado`, `fecha_creacion`, `Comentario`, `id_usr`) VALUES
(1, 'Chile', 'https://flagcdn.com/w320/cl.png', 1, '2025-08-30 17:50:00', NULL, 1),
(2, 'Perú', 'https://flagcdn.com/w320/pe.png', 1, '2025-08-30 17:50:00', NULL, 1),
(3, 'Argentina', 'https://flagcdn.com/w320/ar.png', 1, '2025-08-30 17:50:00', NULL, 1),
(4, 'Bolivia', 'https://flagcdn.com/w320/bo.png', 1, '2025-08-30 17:50:00', NULL, 1),
(5, 'Colombia', 'https://flagcdn.com/w320/co.png', 1, '2025-08-30 17:50:00', NULL, 1),
(6, 'Brasil', 'https://flagcdn.com/w320/br.png', 1, '2025-08-30 17:50:00', NULL, 1),
(7, 'Ecuador', 'https://flagcdn.com/w320/ec.png', 1, '2025-08-30 17:50:00', NULL, 1),
(8, 'Paraguay', 'https://flagcdn.com/w320/py.png', 1, '2025-08-30 17:50:00', NULL, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `receta`
--

CREATE TABLE `receta` (
  `id_receta` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `url_imagen` varchar(255) NOT NULL,
  `ingrediente` text NOT NULL,
  `preparacion` text NOT NULL,
  `estado` tinyint(4) NOT NULL DEFAULT 0,
  `id_cat` int(11) NOT NULL,
  `id_pais` int(11) NOT NULL,
  `fecha_creacion` datetime NOT NULL,
  `id_usr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `receta`
--

INSERT INTO `receta` (`id_receta`, `nombre`, `url_imagen`, `ingrediente`, `preparacion`, `estado`, `id_cat`, `id_pais`, `fecha_creacion`, `id_usr`) VALUES
-- CATEGORÍA 1: Ceviches y Mariscos (5 recetas)
(1, 'Ceviche Peruano Clásico', 'https://www.themealdb.com/images/media/meals/xxrxux1503070723.jpg', '500g de corvina fresca; 8 limones; 1 cebolla roja; 1 ají limo; Cilantro fresco; Sal al gusto; 2 dientes de ajo', 'Cortar el pescado en cubos pequeños. Exprimir los limones y marinar el pescado por 15-20 minutos. Agregar cebolla en juliana, ají picado, ajo machacado y cilantro. Revolver bien y dejar reposar 5 minutos más. Servir frío con cancha serrana.', 1, 1, 2, '2025-08-30', 1),
(2, 'Ceviche Chileno de Ostras', 'https://www.themealdb.com/images/media/meals/wqqvyq1511179730.jpg', '12 ostras frescas; 6 limones; 1 cebolla morada; 1 ají verde; Perejil fresco; Aceite de oliva; Sal marina', 'Abrir las ostras y separar la carne. Exprimir los limones sobre las ostras. Agregar cebolla en juliana fina, ají picado y perejil. Aliñar con aceite de oliva y sal. Dejar marinar 10 minutos. Servir con pan amasado.', 1, 1, 1, '2025-08-30', 1),
(3, 'Tiradito Nikkei Peruano', 'https://www.themealdb.com/images/media/meals/xxrxux1503070723.jpg', '400g de sashimi de atún; 4 limones; 2 ajíes amarillos; Jengibre fresco; Aceite de sésamo; Salsa de soya; Cebollín', 'Cortar el atún en láminas finas. Preparar la salsa con limones, ají amarillo, jengibre y aceite de sésamo. Bañar el atún con la salsa. Decorar con cebollín picado. Servir inmediatamente con chips de camote.', 1, 1, 2, '2025-08-30', 1),
(4, 'Ceviche Ecuatoriano de Camarón', 'https://www.themealdb.com/images/media/meals/uvuyxu1503067369.jpg', '500g de camarones; 6 limones; 1 cebolla blanca; 1 tomate; Cilantro; Ají picante; Maíz tostado', 'Cocinar los camarones 2 minutos en agua con sal. Enfriar y pelar. Marinar con jugo de limón por 10 minutos. Agregar cebolla, tomate y cilantro picados. Sazonar con ají. Servir con maíz tostado y patacones.', 1, 1, 7, '2025-08-30', 1),
(5, 'Ceviche Paraguayo de Surubí', 'https://www.themealdb.com/images/media/meals/1520081754.jpg', '600g de surubí; 8 limones; 1 cebolla; 1 pimiento rojo; Perejil; Aceite; Sal; Mandioca cocida', 'Cortar el pescado en cubos. Marinar con jugo de limón por 20 minutos. Agregar cebolla y pimiento en juliana. Condimentar con perejil, aceite y sal. Servir con mandioca cocida como acompañamiento.', 1, 1, 8, '2025-08-30', 1),

-- CATEGORÍA 2: Carnes Asadas (5 recetas)
(6, 'Asado Argentino con Chimichurri', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg', '1kg de costillas de res; Sal gruesa; Pimienta negra; Chimichurri (perejil, ajo, aceite, vinagre, orégano); Achuras variadas', 'Sazonar la carne con sal y pimienta. Preparar chimichurri mezclando todos los ingredientes. Asar las costillas a fuego medio por 2 horas. Servir con chimichurri y achuras asadas. Acompañar con vino tinto.', 1, 2, 3, '2025-08-30', 1),
(7, 'Churrasco Uruguayo', 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg', '800g de lomo de res; Sal; Pimienta; Chimichurri; Ensalada de repollo; Pan casero', 'Cortar el lomo en medallones gruesos. Sazonar con sal y pimienta. Asar a la parrilla 4-5 minutos por lado. Preparar chimichurri con perejil, ajo, aceite y vinagre. Servir con ensalada y pan.', 1, 2, 3, '2025-08-30', 1),
(8, 'Carne de Res a la Parrilla Colombiana', 'https://www.themealdb.com/images/media/meals/uuqvwu1504629254.jpg', '1kg de punta de anca; Sal; Comino; Ajo; Cúrcuma; Hogao (tomate, cebolla, cilantro); Arroz blanco', 'Marinar la carne con sal, comino, ajo y cúrcuma por 2 horas. Asar a la parrilla hasta el punto deseado. Preparar hogao sofriendo tomate, cebolla y cilantro. Servir la carne con hogao y arroz blanco.', 1, 2, 5, '2025-08-30', 1),
(9, 'Picanha Brasileña', 'https://www.themealdb.com/images/media/meals/atd5sh1583188467.jpg', '1.5kg de picanha; Sal gruesa; Farofa; Vinagrete; Mandioca frita', 'Sazonar la picanha con sal gruesa. Asar con la grasa hacia arriba primero. Cortar en rodajas. Preparar farofa con harina de mandioca y mantequilla. Servir con vinagrete y mandioca frita.', 1, 2, 6, '2025-08-30', 1),
(10, 'Lomo Saltado Peruano', 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg', '500g de lomo fino; 2 cebollas; 2 tomates; Cilantro; Salsa de soya; Vinagre; Papas fritas; Arroz', 'Cortar el lomo en tiras finas. Saltear en wok caliente. Agregar cebolla y tomate en juliana. Condimentar con soya y vinagre. Incorporar cilantro. Servir con papas fritas y arroz blanco.', 1, 2, 2, '2025-08-30', 1),

-- CATEGORÍA 3: Arroces y Guarniciones (5 recetas)
(11, 'Arroz con Coco Colombiano', 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg', '2 tazas de arroz; 1 coco fresco; 1 litro de leche de coco; Azúcar; Canela; Sal', 'Rallar el coco y extraer la leche. Cocinar el arroz con la leche de coco, azúcar, canela y sal. Revolver constantemente hasta que espese. Servir como postre o acompañamiento.', 1, 3, 5, '2025-08-30', 1),
(12, 'Moros y Cristianos Cubanos', 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg', '2 tazas de arroz negro; 1 taza de frijoles negros; 1 cebolla; 2 dientes de ajo; Laurel; Aceite; Sal', 'Cocinar los frijoles con cebolla, ajo y laurel. En otra olla, sofreír arroz con aceite. Agregar frijoles cocidos y caldo. Cocinar hasta que el arroz esté tierno. Servir como guarnición.', 1, 3, 5, '2025-08-30', 1),
(13, 'Arroz Chaufa Peruano', 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg', '2 tazas de arroz cocido; 200g de pollo; 2 huevos; 1 cebolla; Salsa de soya; Kion; Cilantro', 'Saltear pollo con cebolla y kion. Agregar arroz cocido y salsa de soya. Incorporar huevo revuelto. Decorar con cilantro. Servir caliente como plato principal o acompañamiento.', 1, 3, 2, '2025-08-30', 1),
(14, 'Frijoles Charros Mexicanos', 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg', '500g de frijoles pintos; 200g de tocino; 1 cebolla; 2 jitomates; Cilantro; Epazote; Sal', 'Cocinar frijoles hasta que estén suaves. En sartén aparte, freír tocino con cebolla y jitomate. Agregar a los frijoles con cilantro y epazote. Hervir 15 minutos más. Servir como guarnición.', 1, 3, 5, '2025-08-30', 1),
(15, 'Quinoa Chilena con Verduras', 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg', '1 taza de quinoa; 1 zapallo; 1 pimiento; 1 cebolla; Aceite de oliva; Limón; Hierbas', 'Cocinar quinoa en agua con sal. Saltear verduras con aceite. Mezclar quinoa con verduras. Aliñar con limón y hierbas. Servir como saludable guarnición o plato principal vegetariano.', 1, 3, 1, '2025-08-30', 1),

-- CATEGORÍA 4: Postres Tradicionales (5 recetas)
(16, 'Tres Leches Chileno', 'https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg', '4 huevos; 1 taza de azúcar; 1 taza de harina; 1 lata de leche condensada; 1 lata de leche evaporada; 1 taza de crema de leche; Frutas frescas', 'Batir huevos con azúcar hasta esponjar. Agregar harina tamizada. Hornear a 180°C por 25 minutos. Mezclar las tres leches y empapar el bizcocho. Refrigerar 4 horas. Servir con frutas.', 1, 4, 1, '2025-08-30', 1),
(17, 'Alfajores Argentinos', 'https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg', '2 tazas de harina; 200g de mantequilla; 1/2 taza de azúcar glas; 1 lata de dulce de leche; Coco rallado', 'Mezclar harina, mantequilla y azúcar. Formar tapas redondas. Hornear 10 minutos a 180°C. Rellenar con dulce de leche. Espolvorear coco. Dejar reposar antes de servir.', 1, 4, 3, '2025-08-30', 1),
(18, 'Suspiro Limeño Peruano', 'https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg', '1 lata de leche condensada; 4 yemas; 1/2 taza de azúcar; Canela en polvo; Vino dulce', 'Cocinar leche condensada con yemas a baño maría hasta espesar. Caramelizar azúcar para decorar. Servir manjar con merengue y canela. Acompañar con vino dulce.', 1, 4, 2, '2025-08-30', 1),
(19, 'Chocotorta Argentina', 'https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg', '400g de galletas de chocolate; 500g de queso crema; 200g de dulce de leche; 200ml de crema de leche; Chocolate rallado', 'Batir queso crema con dulce de leche. Armar capas alternando galletas y mezcla. Refrigerar 12 horas. Decorar con chocolate rallado. Servir fría.', 1, 4, 3, '2025-08-30', 1),
(20, 'Arroz con Leche Colombiano', 'https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg', '1 taza de arroz; 2 litros de leche; 1 taza de azúcar; Canela; Vainilla; Pasas', 'Cocinar arroz con leche y canela. Agregar azúcar y vainilla. Cocinar a fuego lento hasta espesar. Agregar pasas. Servir frío o tibio.', 1, 4, 5, '2025-08-30', 1),

-- CATEGORÍA 5: Sopas y Caldos (5 recetas)
(21, 'Sancocho Trifásico Colombiano', 'https://www.themealdb.com/images/media/meals/stpuws1511191310.jpg', '500g de costilla de res; 500g de pollo; 500g de cerdo; 2 mazorcas; 2 plátanos verdes; 2 papas; Cilantro; Sal', 'Cocinar carnes con mazorcas y plátanos en abundante agua. Agregar papas y verduras. Cocinar hasta que todo esté tierno. Sazonar con cilantro y sal. Servir caliente.', 1, 5, 5, '2025-08-30', 1),
(22, 'Ajiaco Colombiano', 'https://www.themealdb.com/images/media/meals/stpuws1511191310.jpg', '1 pollo entero; 3 papas criollas; 2 mazorcas; Guascas; Crema de leche; Alcaparras; Aguacate', 'Cocinar pollo con papas y mazorcas. Agregar guascas para dar sabor característico. Desmenuzar pollo. Servir con crema, alcaparras y aguacate.', 1, 5, 5, '2025-08-30', 1),
(23, 'Cazuela Chilena', 'https://www.themealdb.com/images/media/meals/stpuws1511191310.jpg', '500g de carne de vacuno; 2 choclos; 2 papas; 1 zapallo; Cilantro; Comino; Sal', 'Cocinar carne con verduras en olla grande. Sazonar con comino y sal. Agregar cilantro al final. Servir con pan amasado. Plato tradicional chileno.', 1, 5, 1, '2025-08-30', 1),
(24, 'Sopa de Mondongo Peruana', 'https://www.themealdb.com/images/media/meals/stpuws1511191310.jpg', '1kg de mondongo; 2 cebollas; 2 tomates; Cilantro; Cúrcuma; Ajo; Limón; Sal', 'Limpiar y cocinar mondongo hasta ablandar. Sofreír cebolla, tomate y ajo. Agregar al mondongo con cúrcuma. Cocinar 30 minutos más. Servir con limón y cilantro.', 1, 5, 2, '2025-08-30', 1),
(25, 'Caldo Verde Portugués-Brasileño', 'https://www.themealdb.com/images/media/meals/stpuws1511191310.jpg', '500g de collards; 2 cebollas; 4 papas; 200g de chorizo; Aceite de oliva; Sal; Agua', 'Cocinar papas hasta ablandar. Licuar con agua de cocción. Sofreír cebolla y chorizo. Agregar al puré con collards picados. Hervir 10 minutos. Servir con aceite de oliva.', 1, 5, 6, '2025-08-30', 1),

-- CATEGORÍA 6: Antojitos y Aperitivos (5 recetas)
(26, 'Empanadas Chilenas', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg', '500g de harina; 200g de mantequilla; Sal; Agua; Carne molida; Cebolla; Aceitunas; Huevo', 'Preparar masa con harina, mantequilla, sal y agua. Rellenar con carne molida, cebolla y aceitunas. Cerrar y hornear. Pintar con huevo. Servir calientes.', 1, 6, 1, '2025-08-30', 1),
(27, 'Arepas Colombianas', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg', '2 tazas de harina de maíz; 2 tazas de agua; Sal; Queso; Mantequilla; Aguacate', 'Mezclar harina de maíz con agua y sal. Formar arepas y cocinar en sartén. Rellenar con queso, mantequilla y aguacate. Servir calientes como aperitivo.', 1, 6, 5, '2025-08-30', 1),
(28, 'Tamales Mexicanos', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg', '500g de masa de maíz; 200g de manteca; Sal; Hojas de maíz; Pollo deshebrado; Salsa verde', 'Preparar masa con maíz y manteca. Rellenar con pollo y salsa. Envolver en hojas de maíz. Cocinar al vapor 1 hora. Servir calientes.', 1, 6, 5, '2025-08-30', 1),
(29, 'Tequeños Venezolanos', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg', '500g de harina; 200g de mantequilla; Queso blanco; Aceite para freír; Sal', 'Preparar masa con harina, mantequilla y sal. Rellenar con queso blanco. Freír hasta dorar. Servir con salsa de queso o ají.', 1, 6, 5, '2025-08-30', 1),
(30, 'Pasteles Puertorriqueños', 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg', '500g de harina; 200g de manteca; Sal; Carne molida; Papas; Aceitunas; Hojas de guineo', 'Preparar masa con harina y manteca. Rellenar con carne, papas y aceitunas. Envolver en hojas de guineo. Cocinar al vapor. Servir calientes.', 1, 6, 5, '2025-08-30', 1),

-- CATEGORÍA 7: Platos Típicos (5 recetas)
(31, 'Feijoada Brasileña', 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg', '1kg de frijoles negros; 500g de carne seca; 300g de costillas; 200g de chorizo; Arroz blanco; Farofa; Naranja', 'Cocinar frijoles con carnes por 3 horas. Preparar farofa con harina de mandioca. Servir con arroz, farofa y rodajas de naranja. Plato nacional de Brasil.', 1, 7, 6, '2025-08-30', 1),
(32, 'Locro Argentino', 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg', '500g de maíz blanco; 300g de zapallo; 200g de carne; 1 cebolla; Pimentón; Sal; Laurel', 'Cocinar maíz con zapallo y carne. Sofreír cebolla con pimentón. Agregar a la preparación. Cocinar hasta espesar. Servir con chorizo asado.', 1, 7, 3, '2025-08-30', 1),
(33, 'Lapingachos Ecuatorianos', 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg', '1kg de papas; 200g de queso; 1 cebolla; 1 huevo; Aceite; Sal; Chorizo; Aguacate', 'Cocinar y triturar papas. Mezclar con queso, cebolla y huevo. Formar tortitas y freír. Servir con chorizo, aguacate y ensalada. Especialidad ecuatoriana.', 1, 7, 7, '2025-08-30', 1),
(34, 'Humitas Chilenas', 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg', '500g de choclo; 100g de mantequilla; 1 cebolla; Sal; Hojas de maíz; Queso opcional', 'Licuar choclo con mantequilla y cebolla. Sazonar con sal. Envolver en hojas de maíz. Cocinar al vapor 30 minutos. Servir calientes.', 1, 7, 1, '2025-08-30', 1),
(35, 'Sopa Paraguaya', 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg', '2 tazas de harina de maíz; 4 huevos; 1 taza de leche; 100g de mantequilla; 200g de queso; Sal', 'Mezclar harina con huevos, leche y mantequilla derretida. Agregar queso rallado y sal. Hornear a 180°C por 40 minutos. Servir como pan o acompañamiento.', 1, 7, 8, '2025-08-30', 1),

-- CATEGORÍA 8: Ensaladas Frescas (5 recetas)
(36, 'Ensalada Chilena', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '2 tomates; 1 cebolla; 1 pepino; Cilantro; Aceite de oliva; Vinagre; Sal; Ají verde', 'Cortar verduras en juliana. Mezclar con cilantro. Aliñar con aceite, vinagre y sal. Agregar ají picado. Dejar reposar 15 minutos.', 1, 8, 1, '2025-08-30', 1),
(37, 'Ensalada de Palta Peruana', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '2 aguacates; 1 cebolla roja; 1 limón; Cilantro; Aceite; Sal; Pimienta; Tomate opcional', 'Cortar aguacates en cubos. Mezclar con cebolla en juliana. Aliñar con limón, aceite, sal y pimienta. Agregar cilantro. Servir fresca.', 1, 8, 2, '2025-08-30', 1),
(38, 'Ensalada de Repollo Brasileña', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '1 repollo; 2 zanahorias; 1 cebolla; Vinagre; Aceite; Sal; Pimienta; Perejil', 'Rallar repollo y zanahorias. Picar cebolla finamente. Mezclar con perejil. Aliñar con vinagre, aceite, sal y pimienta. Dejar reposar.', 1, 8, 6, '2025-08-30', 1),
(39, 'Ensalada de Tomate Colombiana', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '4 tomates; 1 cebolla; Cilantro; Limón; Aceite de oliva; Sal; Pimienta; Queso fresco opcional', 'Cortar tomates en rodajas. Agregar cebolla en juliana. Condimentar con cilantro, limón, aceite, sal y pimienta. Agregar queso si se desea.', 1, 8, 5, '2025-08-30', 1),
(40, 'Ensalada de Remolacha Boliviana', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '4 remolachas; 1 cebolla; Perejil; Vinagre; Aceite; Sal; Pimienta; Queso feta opcional', 'Cocinar remolachas y cortar en rodajas. Mezclar con cebolla y perejil. Aliñar con vinagre, aceite, sal y pimienta. Servir fría.', 1, 8, 4, '2025-08-30', 1),

-- CATEGORÍA 9: Bebidas Tradicionales (5 recetas)
(41, 'Pisco Sour Chileno', 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg', '60ml de pisco; 30ml de jarabe de azúcar; 30ml de limón; 1 clara de huevo; Hielo; Angostura', 'Agitar todos los ingredientes con hielo. Colar en copa. Agregar gotas de angostura. Servir frío. Cóctel nacional de Chile.', 1, 9, 1, '2025-08-30', 1),
(42, 'Aguardiente Antioqueño', 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg', '50ml de aguardiente; Panela; Limón; Hielo; Agua mineral', 'Mezclar aguardiente con panela disuelta en agua. Agregar limón y hielo. Servir en vaso alto. Bebida tradicional de Colombia.', 1, 9, 5, '2025-08-30', 1),
(43, 'Caipirinha Brasileña', 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg', '50ml de cachaça; 1 limón; 2 cucharadas de azúcar; Hielo; Lima opcional', 'Cortar limón en gajos y macerar con azúcar. Agregar cachaça y hielo. Revolver bien. Servir en vaso bajo. Cóctel nacional de Brasil.', 1, 9, 6, '2025-08-30', 1),
(44, 'Mate Argentino', 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg', 'Yerba mate; Agua caliente; Termo; Bombilla; Azúcar opcional', 'Llenar mate con yerba hasta 3/4. Agregar agua caliente. Cebar con bombilla. Beber lentamente. Bebida social tradicional de Argentina.', 1, 9, 3, '2025-08-30', 1),
(45, 'Chicha Morada Peruana', 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg', '1kg de maíz morado; 1 piña; 2 manzanas; Canela; Clavos; Azúcar; Limón; Hielo', 'Cocinar maíz morado con especias. Agregar frutas picadas. Endulzar con azúcar. Colar y enfriar. Servir con hielo. Bebida refrescante típica.', 1, 9, 2, '2025-08-30', 1),

-- CATEGORÍA 10: Platos Vegetarianos (5 recetas)
(46, 'Porotos Granados Chilenos', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '500g de porotos verdes; 2 cebollas; 1 zapallo; Albahaca; Aceite; Sal; Comino; Huevo duro', 'Cocinar porotos con zapallo. Sofreír cebolla con comino. Mezclar todo con albahaca. Servir con huevo duro. Plato vegetariano tradicional.', 1, 10, 1, '2025-08-30', 1),
(47, 'Llapingachos Ecuatorianos Vegetarianos', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '1kg de papas; 200g de queso; 1 cebolla; 1 huevo; Aceite; Sal; Ensalada; Aguacate', 'Cocinar y triturar papas. Mezclar con queso, cebolla y huevo. Formar tortitas y freír. Servir con ensalada y aguacate. Versión vegetariana.', 1, 10, 7, '2025-08-30', 1),
(48, 'Falafel con Tahini Peruano', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '500g de garbanzos; 1 cebolla; Cilantro; Ajo; Comino; Tahini; Limón; Aceite', 'Remojar garbanzos y moler con especias. Formar bolitas y freír. Preparar salsa de tahini con limón. Servir con verduras frescas.', 1, 10, 2, '2025-08-30', 1),
(49, 'Quinoa con Verduras Colombianas', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '1 taza de quinoa; 2 zanahorias; 1 pimiento; 1 cebolla; Cilantro; Limón; Aceite; Sal', 'Cocinar quinoa. Saltear verduras con aceite. Mezclar todo con cilantro. Aliñar con limón y sal. Plato saludable y completo.', 1, 10, 5, '2025-08-30', 1),
(50, 'Humitas Vegetarianas Bolivianas', 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg', '500g de choclo; 100g de queso; 1 cebolla; Sal; Hojas de maíz; Mantequilla; Leche opcional', 'Licuar choclo con queso y cebolla. Sazonar con sal. Envolver en hojas de maíz. Cocinar al vapor 30 minutos. Servir calientes.', 1, 10, 4, '2025-08-30', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usr` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `estado` tinyint(4) NOT NULL DEFAULT 0,
  `fecha_creacion` datetime NOT NULL,
  `id_pais` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usr`, `nombre`, `apellido`, `email`, `password`, `estado`, `fecha_creacion`, `id_pais`) VALUES
(1, 'Admin', 'Sistema', 'admin@recetaslatino.com', '$2a$10$encryptedpassword', 1, '2025-08-30 17:50:00', 1),
(2, 'Chef', 'Latino', 'chef@recetaslatino.com', '$2a$10$encryptedpassword', 1, '2025-08-30 17:50:00', 2),
(3, 'Usuario', 'Prueba', 'usuario@recetaslatino.com', '$2a$10$encryptedpassword', 1, '2025-08-30 17:50:00', 3);

-- --------------------------------------------------------

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`id_cat`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `pais`
--
ALTER TABLE `pais`
  ADD PRIMARY KEY (`id_pais`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `receta`
--
ALTER TABLE `receta`
  ADD PRIMARY KEY (`id_receta`),
  ADD KEY `id_cat` (`id_cat`),
  ADD KEY `id_pais` (`id_pais`),
  ADD KEY `id_usr` (`id_usr`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usr`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `id_pais` (`id_pais`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `id_cat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `pais`
--
ALTER TABLE `pais`
  MODIFY `id_pais` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `receta`
--
ALTER TABLE `receta`
  MODIFY `id_receta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `receta`
--
ALTER TABLE `receta`
  ADD CONSTRAINT `receta_ibfk_1` FOREIGN KEY (`id_cat`) REFERENCES `categoria` (`id_cat`),
  ADD CONSTRAINT `receta_ibfk_2` FOREIGN KEY (`id_pais`) REFERENCES `pais` (`id_pais`),
  ADD CONSTRAINT `receta_ibfk_3` FOREIGN KEY (`id_usr`) REFERENCES `usuario` (`id_usr`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_pais`) REFERENCES `pais` (`id_pais`);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
