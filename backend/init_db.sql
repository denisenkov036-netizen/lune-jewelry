-- =============================================
-- LUNE JEWELRY
-- Database: SQLite
-- =============================================

PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS product_sizes;
DROP TABLE IF EXISTS product_stones;
DROP TABLE IF EXISTS product_materials;
DROP TABLE IF EXISTS product_images;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS design_styles;
DROP TABLE IF EXISTS stones;
DROP TABLE IF EXISTS materials;
DROP TABLE IF EXISTS jewelry_types;
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- 1. ТИПИ ПРИКРАС
CREATE TABLE IF NOT EXISTS jewelry_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- 2. МАТЕРІАЛИ
CREATE TABLE IF NOT EXISTS materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    color_code TEXT
);

-- 3. КАМЕНІ
CREATE TABLE IF NOT EXISTS stones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    color_code TEXT
);

-- 4. ТОВАРИ
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    price_uah INTEGER NOT NULL CHECK (price_uah > 0),
    weight_grams REAL CHECK (
        weight_grams IS NULL OR weight_grams > 0
    ),
    type_id INTEGER NOT NULL,
    model_url TEXT,
    is_featured INTEGER NOT NULL DEFAULT 0
        CHECK (is_featured IN (0, 1)),
    popularity_score INTEGER NOT NULL DEFAULT 0
        CHECK (popularity_score >= 0),
    rating REAL NOT NULL DEFAULT 0
        CHECK (rating >= 0 AND rating <= 5),
    reviews_count INTEGER NOT NULL DEFAULT 0
        CHECK (reviews_count >= 0),
    is_active INTEGER NOT NULL DEFAULT 1
        CHECK (is_active IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (type_id) REFERENCES jewelry_types(id)
);

-- 5. ФОТОГРАФІЇ ТОВАРІВ
CREATE TABLE IF NOT EXISTS product_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    image_url TEXT NOT NULL,
    is_primary INTEGER NOT NULL DEFAULT 0
        CHECK (is_primary IN (0, 1)),
    sort_order INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE,

    UNIQUE (product_id, image_url)
);

-- Для кожного товару дозволено лише одне головне фото
CREATE UNIQUE INDEX IF NOT EXISTS idx_one_primary_image
ON product_images(product_id)
WHERE is_primary = 1;

-- 6. МАТЕРІАЛИ, ДОСТУПНІ ДЛЯ ТОВАРІВ
CREATE TABLE IF NOT EXISTS product_materials (
    product_id INTEGER NOT NULL,
    material_id INTEGER NOT NULL,

    PRIMARY KEY (product_id, material_id),

    FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE,

    FOREIGN KEY (material_id) REFERENCES materials(id)
);

-- 7. КАМЕНІ У ТОВАРАХ
CREATE TABLE IF NOT EXISTS product_stones (
    product_id INTEGER NOT NULL,
    stone_id INTEGER NOT NULL,

    PRIMARY KEY (product_id, stone_id),

    FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE,

    FOREIGN KEY (stone_id) REFERENCES stones(id)
);

-- 8. РОЗМІРИ ТОВАРІВ
CREATE TABLE IF NOT EXISTS product_sizes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    size_label TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE,

    UNIQUE (product_id, size_label)
);

-- =============================================
-- ДОВІДНИКИ
-- =============================================

INSERT OR IGNORE INTO jewelry_types (name) VALUES
('Каблучка'),
('Сережки'),
('Підвіска'),
('Браслет');

INSERT OR IGNORE INTO materials (name, color_code) VALUES
('Срібло 925', '#C0C0C0'),
('Жовте золото 585', '#D4AF37'),
('Біле золото 585', '#E5E4E2'),
('Рожеве золото 585', '#B76E79'),
('Платина 950', '#D8D8D8');

INSERT OR IGNORE INTO stones (name, color_code) VALUES
('Сапфір', '#173B70'),
('Перлина', '#F4F0E8'),
('Фіаніт', '#E8E8F0'),
('Топаз', '#75B9E7');

-- =============================================
-- ТОВАРИ
-- =============================================

INSERT OR IGNORE INTO products
(name, description, price_uah, weight_grams,
 type_id, model_url, is_featured,
 popularity_score, rating, reviews_count)
VALUES
(
    'Каблучка «Нічний сапфір»',
    'Класична каблучка з центральним круглим сапфіром насиченого синього відтінку у чотирьох крапанах.',
    24800, 3.40,
    (SELECT id FROM jewelry_types WHERE name = 'Каблучка'),
    '/models/ring.glb',
    1, 98, 4.9, 12
),
(
    'Сережки «Квітка опівночі»',
    'Ажурні сережки-підвіски у формі пелюсток сакури, інкрустовані синіми сапфірами.',
    20500, 4.60,
    (SELECT id FROM jewelry_types WHERE name = 'Сережки'),
    '/models/earrings.glb',
    1, 95, 4.8, 9
),
(
    'Підвіска «Серп місяця»',
    'Витончений кулон у формі півмісяця з мініатюрним синім каменем на тонкому ланцюжку.',
    9600, 2.90,
    (SELECT id FROM jewelry_types WHERE name = 'Підвіска'),
    '/models/pendant.glb',
    1, 92, 5.0, 7
),
(
    'Браслет «Тиха хвиля»',
    'Лаконічний срібний браслет із плавними лініями та витонченим силуетом.',
    4900, 5.20,
    (SELECT id FROM jewelry_types WHERE name = 'Браслет'),
    NULL,
    1, 88, 4.7, 6
),
(
    'Каблучка «Орбіта»',
    'Золота каблучка з геометричним дизайном та акуратними декоративними елементами.',
    17500, 3.80,
    (SELECT id FROM jewelry_types WHERE name = 'Каблучка'),
    NULL,
    0, 75, 4.8, 5
),
(
    'Сережки «Перлинний ранок»',
    'Витончені сережки з ніжними перлинами для повсякденних та святкових образів.',
    15200, 4.00,
    (SELECT id FROM jewelry_types WHERE name = 'Сережки'),
    NULL,
    0, 70, 4.6, 4
),
(
    'Підвіска «Сонячний промінь»',
    'Золота підвіска з невеликим прозорим каменем та витонченим декоративним оформленням.',
    7900, 2.50,
    (SELECT id FROM jewelry_types WHERE name = 'Підвіска'),
    NULL,
    0, 65, 4.7, 3
),
(
    'Каблучка «Лінія світла»',
    'Витончена каблучка з плавним дизайном та ніжним рожевим відтінком металу.',
    14300, 3.10,
    (SELECT id FROM jewelry_types WHERE name = 'Каблучка'),
    NULL,
    0, 58, 4.9, 4
),
(
    'Браслет «Сузір’я»',
    'Срібний браслет із невеликими декоративними вставками, натхненний зоряним небом.',
    32500, 5.60,
    (SELECT id FROM jewelry_types WHERE name = 'Браслет'),
    NULL,
    0, 50, 4.5, 2
);

-- =============================================
-- ФОТОГРАФІЇ: 3 НА КОЖЕН ТОВАР
-- =============================================

INSERT OR IGNORE INTO product_images
(product_id, image_url, is_primary, sort_order)
SELECT p.id, v.image_url, v.is_primary, v.sort_order
FROM (
    SELECT 'Каблучка «Нічний сапфір»' AS product_name,
           '/images/ring.jpg' AS image_url, 1 AS is_primary, 1 AS sort_order
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', '/images/ring-side.jpg', 0, 2
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', '/images/ring-detail.jpg', 0, 3

    UNION ALL SELECT 'Сережки «Квітка опівночі»', '/images/earrings.jpg', 1, 1
    UNION ALL SELECT 'Сережки «Квітка опівночі»', '/images/earrings-side.jpg', 0, 2
    UNION ALL SELECT 'Сережки «Квітка опівночі»', '/images/earrings-detail.jpg', 0, 3

    UNION ALL SELECT 'Підвіска «Серп місяця»', '/images/pendant.jpg', 1, 1
    UNION ALL SELECT 'Підвіска «Серп місяця»', '/images/pendant-side.jpg', 0, 2
    UNION ALL SELECT 'Підвіска «Серп місяця»', '/images/pendant-detail.jpg', 0, 3

    UNION ALL SELECT 'Браслет «Тиха хвиля»', '/images/bracelet.jpg', 1, 1
    UNION ALL SELECT 'Браслет «Тиха хвиля»', '/images/bracelet-side.jpg', 0, 2
    UNION ALL SELECT 'Браслет «Тиха хвиля»', '/images/bracelet-detail.jpg', 0, 3

    UNION ALL SELECT 'Каблучка «Орбіта»', '/images/ring-orbita.jpg', 1, 1
    UNION ALL SELECT 'Каблучка «Орбіта»', '/images/ring-orbita-side.jpg', 0, 2
    UNION ALL SELECT 'Каблучка «Орбіта»', '/images/ring-orbita-detail.jpg', 0, 3

    UNION ALL SELECT 'Сережки «Перлинний ранок»', '/images/pearl-earrings.jpg', 1, 1
    UNION ALL SELECT 'Сережки «Перлинний ранок»', '/images/pearl-earrings-side.jpg', 0, 2
    UNION ALL SELECT 'Сережки «Перлинний ранок»', '/images/pearl-earrings-detail.jpg', 0, 3

    UNION ALL SELECT 'Підвіска «Сонячний промінь»', '/images/sun-pendant.jpg', 1, 1
    UNION ALL SELECT 'Підвіска «Сонячний промінь»', '/images/sun-pendant-side.jpg', 0, 2
    UNION ALL SELECT 'Підвіска «Сонячний промінь»', '/images/sun-pendant-detail.jpg', 0, 3

    UNION ALL SELECT 'Каблучка «Лінія світла»', '/images/light-ring.jpg', 1, 1
    UNION ALL SELECT 'Каблучка «Лінія світла»', '/images/light-ring-side.jpg', 0, 2
    UNION ALL SELECT 'Каблучка «Лінія світла»', '/images/light-ring-detail.jpg', 0, 3

    UNION ALL SELECT 'Браслет «Сузір’я»', '/images/constellation-bracelet.jpg', 1, 1
    UNION ALL SELECT 'Браслет «Сузір’я»', '/images/constellation-bracelet-side.jpg', 0, 2
    UNION ALL SELECT 'Браслет «Сузір’я»', '/images/constellation-bracelet-detail.jpg', 0, 3
) AS v
JOIN products p ON p.name = v.product_name;

-- =============================================
-- МАТЕРІАЛИ ТОВАРІВ
-- =============================================

INSERT OR IGNORE INTO product_materials
(product_id, material_id)
SELECT p.id, m.id
FROM (
    SELECT 'Каблучка «Нічний сапфір»' AS product_name, 'Срібло 925' AS material_name
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', 'Біле золото 585'

    UNION ALL SELECT 'Сережки «Квітка опівночі»', 'Срібло 925'
    UNION ALL SELECT 'Сережки «Квітка опівночі»', 'Біле золото 585'

    UNION ALL SELECT 'Підвіска «Серп місяця»', 'Срібло 925'
    UNION ALL SELECT 'Підвіска «Серп місяця»', 'Біле золото 585'

    UNION ALL SELECT 'Браслет «Тиха хвиля»', 'Срібло 925'
    UNION ALL SELECT 'Браслет «Тиха хвиля»', 'Жовте золото 585'

    UNION ALL SELECT 'Каблучка «Орбіта»', 'Жовте золото 585'
    UNION ALL SELECT 'Каблучка «Орбіта»', 'Біле золото 585'

    UNION ALL SELECT 'Сережки «Перлинний ранок»', 'Біле золото 585'
    UNION ALL SELECT 'Сережки «Перлинний ранок»', 'Срібло 925'

    UNION ALL SELECT 'Підвіска «Сонячний промінь»', 'Жовте золото 585'
    UNION ALL SELECT 'Підвіска «Сонячний промінь»', 'Рожеве золото 585'

    UNION ALL SELECT 'Каблучка «Лінія світла»', 'Рожеве золото 585'
    UNION ALL SELECT 'Каблучка «Лінія світла»', 'Біле золото 585'

    UNION ALL SELECT 'Браслет «Сузір’я»', 'Срібло 925'
    UNION ALL SELECT 'Браслет «Сузір’я»', 'Платина 950'
) AS v
JOIN products p ON p.name = v.product_name
JOIN materials m ON m.name = v.material_name;

-- =============================================
-- КАМЕНІ ТОВАРІВ
-- =============================================

INSERT OR IGNORE INTO product_stones
(product_id, stone_id)
SELECT p.id, s.id
FROM (
    SELECT 'Каблучка «Нічний сапфір»' AS product_name, 'Сапфір' AS stone_name
    UNION ALL SELECT 'Сережки «Квітка опівночі»', 'Сапфір'
    UNION ALL SELECT 'Підвіска «Серп місяця»', 'Сапфір'
    UNION ALL SELECT 'Сережки «Перлинний ранок»', 'Перлина'
    UNION ALL SELECT 'Підвіска «Сонячний промінь»', 'Фіаніт'
    UNION ALL SELECT 'Браслет «Сузір’я»', 'Фіаніт'
    UNION ALL SELECT 'Каблучка «Орбіта»', 'Топаз'
) AS v
JOIN products p ON p.name = v.product_name
JOIN stones s ON s.name = v.stone_name;

-- =============================================
-- РОЗМІРИ КАБЛУЧОК
-- =============================================

INSERT OR IGNORE INTO product_sizes
(product_id, size_label, sort_order)
SELECT p.id, v.size_label, v.sort_order
FROM (
    SELECT 'Каблучка «Нічний сапфір»' AS product_name, '15' AS size_label, 1 AS sort_order
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', '16', 2
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', '17', 3
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', '18', 4
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', '19', 5
    UNION ALL SELECT 'Каблучка «Нічний сапфір»', '20', 6

    UNION ALL SELECT 'Каблучка «Орбіта»', '15', 1
    UNION ALL SELECT 'Каблучка «Орбіта»', '16', 2
    UNION ALL SELECT 'Каблучка «Орбіта»', '17', 3
    UNION ALL SELECT 'Каблучка «Орбіта»', '18', 4
    UNION ALL SELECT 'Каблучка «Орбіта»', '19', 5
    UNION ALL SELECT 'Каблучка «Орбіта»', '20', 6

    UNION ALL SELECT 'Каблучка «Лінія світла»', '15', 1
    UNION ALL SELECT 'Каблучка «Лінія світла»', '16', 2
    UNION ALL SELECT 'Каблучка «Лінія світла»', '17', 3
    UNION ALL SELECT 'Каблучка «Лінія світла»', '18', 4
    UNION ALL SELECT 'Каблучка «Лінія світла»', '19', 5
    UNION ALL SELECT 'Каблучка «Лінія світла»', '20', 6
) AS v
JOIN products p ON p.name = v.product_name;

-- =============================================
-- ІНДЕКСИ ДЛЯ ПОШУКУ ТА ФІЛЬТРАЦІЇ
-- =============================================

CREATE INDEX IF NOT EXISTS idx_products_type
ON products(type_id);

CREATE INDEX IF NOT EXISTS idx_products_price
ON products(price_uah);

CREATE INDEX IF NOT EXISTS idx_products_popularity
ON products(popularity_score);

CREATE INDEX IF NOT EXISTS idx_products_featured
ON products(is_featured);

CREATE INDEX IF NOT EXISTS idx_product_materials_material
ON product_materials(material_id);

CREATE INDEX IF NOT EXISTS idx_product_stones_stone
ON product_stones(stone_id);

COMMIT;