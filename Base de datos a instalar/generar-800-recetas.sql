-- Script SQL para generar automáticamente 800 recetas latinoamericanas
-- 10 categorías × 8 países × 10 recetas = 800 recetas totales

-- Función para generar recetas automáticamente
DO $$
DECLARE
    categoria_record RECORD;
    pais_record RECORD;
    receta_count INTEGER := 0;
    max_recetas INTEGER := 10; -- 10 recetas por combinación categoría-país
    usuario_id INTEGER := 4; -- ID del usuario Admin
BEGIN
    -- Recorrer todas las categorías
    FOR categoria_record IN SELECT id_cat, nombre FROM categoria ORDER BY id_cat LOOP
        -- Recorrer todos los países
        FOR pais_record IN SELECT id_pais, nombre FROM pais ORDER BY id_pais LOOP
            -- Generar 10 recetas por combinación
            FOR i IN 1..max_recetas LOOP
                receta_count := receta_count + 1;

                -- Insertar receta con datos generados automáticamente
                INSERT INTO receta (
                    nombre,
                    url_imagen,
                    ingrediente,
                    preparacion,
                    estado,
                    id_cat,
                    id_pais,
                    fecha_creacion,
                    id_usr
                ) VALUES (
                    -- Nombre de la receta
                    categoria_record.nombre || ' ' || pais_record.nombre || ' #' || i,

                    -- URL de imagen (usando imágenes de TheMealDB)
                    CASE
                        WHEN categoria_record.nombre = 'Ceviches y Mariscos' THEN 'https://www.themealdb.com/images/media/meals/xxrxux1503070723.jpg'
                        WHEN categoria_record.nombre = 'Carnes Asadas' THEN 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg'
                        WHEN categoria_record.nombre = 'Postres Tradicionales' THEN 'https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg'
                        WHEN categoria_record.nombre = 'Sopas y Caldos' THEN 'https://www.themealdb.com/images/media/meals/stpuws1511191310.jpg'
                        WHEN categoria_record.nombre = 'Antojitos y Aperitivos' THEN 'https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg'
                        WHEN categoria_record.nombre = 'Platos Típicos' THEN 'https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg'
                        WHEN categoria_record.nombre = 'Ensaladas Frescas' THEN 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg'
                        WHEN categoria_record.nombre = 'Bebidas Tradicionales' THEN 'https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg'
                        WHEN categoria_record.nombre = 'Platos Vegetarianos' THEN 'https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg'
                        ELSE 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg'
                    END,

                    -- Ingredientes (generados automáticamente según categoría)
                    CASE
                        WHEN categoria_record.nombre = 'Ceviches y Mariscos' THEN
                            '500g de pescado fresco; ' || (i*50+200) || 'ml de limón; 1 cebolla; Ají; Cilantro; Sal'
                        WHEN categoria_record.nombre = 'Carnes Asadas' THEN
                            (i*200+300) || 'g de carne; Sal; Pimienta; Chimichurri; Aceite; Ajo'
                        WHEN categoria_record.nombre = 'Postres Tradicionales' THEN
                            (i*100+200) || 'g de azúcar; Harina; Huevos; Leche; Frutas de temporada'
                        WHEN categoria_record.nombre = 'Sopas y Caldos' THEN
                            'Verduras frescas; ' || (i*100+500) || 'ml de caldo; Carne o pollo; Condimentos'
                        WHEN categoria_record.nombre = 'Antojitos y Aperitivos' THEN
                            'Harina; Queso; Carne molida; Verduras; Aceite para freír'
                        WHEN categoria_record.nombre = 'Platos Típicos' THEN
                            'Ingredientes tradicionales de ' || pais_record.nombre || '; Especias locales; Verduras frescas'
                        WHEN categoria_record.nombre = 'Ensaladas Frescas' THEN
                            'Lechuga; Tomate; Pepino; Cebolla; Aceite de oliva; Limón'
                        WHEN categoria_record.nombre = 'Bebidas Tradicionales' THEN
                            'Agua; Azúcar; Frutas frescas; Hielo; Especias tradicionales'
                        WHEN categoria_record.nombre = 'Platos Vegetarianos' THEN
                            'Verduras frescas; Legumbres; Cereales; Queso; Hierbas aromáticas'
                        ELSE 'Arroz; Frijoles; Verduras; Carne o pollo; Condimentos'
                    END,

                    -- Preparación (generada automáticamente)
                    CASE
                        WHEN categoria_record.nombre = 'Ceviches y Mariscos' THEN
                            'Cortar el pescado en cubos. Marinar con limón por ' || (i*5+10) || ' minutos. Agregar cebolla, ají y cilantro. Dejar reposar y servir frío.'
                        WHEN categoria_record.nombre = 'Carnes Asadas' THEN
                            'Sazonar la carne con sal y pimienta. Asar a la parrilla por ' || (i*2+8) || ' minutos por lado. Preparar chimichurri y servir caliente.'
                        WHEN categoria_record.nombre = 'Postres Tradicionales' THEN
                            'Mezclar los ingredientes secos. Agregar huevos y leche. Hornear a 180°C por ' || (i*5+25) || ' minutos. Dejar enfriar y servir.'
                        WHEN categoria_record.nombre = 'Sopas y Caldos' THEN
                            'Cocinar los ingredientes en abundante agua. Sazonar al gusto. Hervir por ' || (i*10+30) || ' minutos. Servir caliente.'
                        WHEN categoria_record.nombre = 'Antojitos y Aperitivos' THEN
                            'Preparar la masa con harina y agua. Rellenar con los ingredientes. Freír hasta dorar. Servir caliente.'
                        WHEN categoria_record.nombre = 'Platos Típicos' THEN
                            'Cocinar los ingredientes tradicionales siguiendo la receta típica de ' || pais_record.nombre || '. Servir con guarniciones locales.'
                        WHEN categoria_record.nombre = 'Ensaladas Frescas' THEN
                            'Lavar y cortar todas las verduras. Mezclar en un bowl. Aliñar con aceite y limón. Dejar reposar antes de servir.'
                        WHEN categoria_record.nombre = 'Bebidas Tradicionales' THEN
                            'Mezclar todos los ingredientes en una jarra. Agitar bien. Servir frío con hielo. Disfrutar de esta bebida refrescante.'
                        WHEN categoria_record.nombre = 'Platos Vegetarianos' THEN
                            'Cocinar las verduras al vapor. Mezclar con legumbres. Sazonar con hierbas. Servir como plato principal saludable.'
                        ELSE 'Cocinar el arroz. Preparar el acompañamiento. Mezclar todo. Servir caliente con condimentos.'
                    END,

                    -- Estado (todas activas)
                    1,

                    -- IDs de categoría y país
                    categoria_record.id_cat,
                    pais_record.id_pais,

                    -- Fecha de creación
                    CURRENT_TIMESTAMP,

                    -- ID del usuario
                    usuario_id
                );
            END LOOP;
        END LOOP;
    END LOOP;

    -- Mostrar resumen
    RAISE NOTICE 'Se generaron % recetas automáticamente', receta_count;
END $$;
