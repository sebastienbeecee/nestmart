/*
  # Insertion des données d'exemple

  1. Données de base
    - Catégories principales (Groceries, Electronics, Fashion)
    - Sous-catégories correspondantes
    - Produits d'exemple avec leurs variantes et images

  2. Structure
    - Respect des relations entre tables
    - Données cohérentes avec le fichier db.json original
*/

-- Insertion des catégories principales
INSERT INTO categories (cat_name, image, color) VALUES
('Groceries', 'https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg', '#3bb77e'),
('Electronics', 'https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg', '#fdc040'),
('Fashion', 'https://images.pexels.com/photos/996329/pexels-photo-996329.jpeg', '#f74b81')
ON CONFLICT DO NOTHING;

-- Récupération des IDs des catégories pour les sous-catégories
DO $$
DECLARE
    groceries_id uuid;
    electronics_id uuid;
    fashion_id uuid;
BEGIN
    SELECT id INTO groceries_id FROM categories WHERE cat_name = 'Groceries';
    SELECT id INTO electronics_id FROM categories WHERE cat_name = 'Electronics';
    SELECT id INTO fashion_id FROM categories WHERE cat_name = 'Fashion';

    -- Insertion des sous-catégories pour Groceries
    INSERT INTO subcategories (category_id, cat_name) VALUES
    (groceries_id, 'Milk & Dairies'),
    (groceries_id, 'Wines & Drinks'),
    (groceries_id, 'Clothing & Beauty'),
    (groceries_id, 'Fresh Seafood'),
    (groceries_id, 'Pet Foods & Toy'),
    (groceries_id, 'Fast food'),
    (groceries_id, 'Baking material'),
    (groceries_id, 'Vegetables'),
    (groceries_id, 'Fresh Fruit'),
    (groceries_id, 'Bread & Juice')
    ON CONFLICT DO NOTHING;

    -- Insertion des sous-catégories pour Electronics
    INSERT INTO subcategories (category_id, cat_name) VALUES
    (electronics_id, 'Smartphones'),
    (electronics_id, 'Laptops'),
    (electronics_id, 'Headphones'),
    (electronics_id, 'Cameras'),
    (electronics_id, 'Gaming'),
    (electronics_id, 'Smart Home'),
    (electronics_id, 'Wearables'),
    (electronics_id, 'Audio & Video'),
    (electronics_id, 'Computer Accessories'),
    (electronics_id, 'Mobile Accessories')
    ON CONFLICT DO NOTHING;

    -- Insertion des sous-catégories pour Fashion
    INSERT INTO subcategories (category_id, cat_name) VALUES
    (fashion_id, 'Men Clothing'),
    (fashion_id, 'Women Clothing'),
    (fashion_id, 'Shoes'),
    (fashion_id, 'Bags'),
    (fashion_id, 'Accessories'),
    (fashion_id, 'Jewelry'),
    (fashion_id, 'Watches'),
    (fashion_id, 'Sunglasses'),
    (fashion_id, 'Beauty Products'),
    (fashion_id, 'Perfumes')
    ON CONFLICT DO NOTHING;
END $$;

-- Insertion de quelques produits d'exemple
DO $$
DECLARE
    milk_dairies_id uuid;
    smartphones_id uuid;
    men_clothing_id uuid;
    product_uuid uuid;
BEGIN
    SELECT id INTO milk_dairies_id FROM subcategories WHERE cat_name = 'Milk & Dairies';
    SELECT id INTO smartphones_id FROM subcategories WHERE cat_name = 'Smartphones';
    SELECT id INTO men_clothing_id FROM subcategories WHERE cat_name = 'Men Clothing';

    -- Produit 1: Lait
    INSERT INTO products (product_id, subcategory_id, product_name, cat_img, description, brand, price, old_price, discount, rating, type, is_featured, stock_quantity)
    VALUES (1, milk_dairies_id, 'Fresh Organic Milk', 'https://images.pexels.com/photos/416978/pexels-photo-416978.jpeg', 'Premium organic milk from grass-fed cows', 'Organic Valley', 4.99, 5.99, 17, 4.5, 'new', true, 50)
    RETURNING id INTO product_uuid;

    -- Images pour le produit lait
    INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
    (product_uuid, 'https://images.pexels.com/photos/416978/pexels-photo-416978.jpeg', true, 1),
    (product_uuid, 'https://images.pexels.com/photos/1435735/pexels-photo-1435735.jpeg', false, 2);

    -- Variantes pour le produit lait
    INSERT INTO product_variants (product_id, variant_type, variant_value) VALUES
    (product_uuid, 'weight', '500'),
    (product_uuid, 'weight', '1000'),
    (product_uuid, 'weight', '2000');

    -- Produit 2: Smartphone
    INSERT INTO products (product_id, subcategory_id, product_name, cat_img, description, brand, price, old_price, discount, rating, type, is_featured, stock_quantity)
    VALUES (2, smartphones_id, 'Premium Smartphone X1', 'https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg', 'Latest flagship smartphone with advanced features', 'TechBrand', 899.99, 999.99, 10, 4.8, 'hot', true, 25)
    RETURNING id INTO product_uuid;

    -- Images pour le smartphone
    INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
    (product_uuid, 'https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg', true, 1),
    (product_uuid, 'https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg', false, 2);

    -- Variantes pour le smartphone
    INSERT INTO product_variants (product_id, variant_type, variant_value) VALUES
    (product_uuid, 'ram', '8'),
    (product_uuid, 'ram', '12'),
    (product_uuid, 'ram', '16');

    -- Produit 3: T-shirt homme
    INSERT INTO products (product_id, subcategory_id, product_name, cat_img, description, brand, price, old_price, discount, rating, type, is_featured, stock_quantity)
    VALUES (3, men_clothing_id, 'Classic Cotton T-Shirt', 'https://images.pexels.com/photos/1020585/pexels-photo-1020585.jpeg', 'Comfortable cotton t-shirt for everyday wear', 'FashionCo', 29.99, 39.99, 25, 4.2, 'sale', false, 100)
    RETURNING id INTO product_uuid;

    -- Images pour le t-shirt
    INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
    (product_uuid, 'https://images.pexels.com/photos/1020585/pexels-photo-1020585.jpeg', true, 1),
    (product_uuid, 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg', false, 2);

    -- Variantes pour le t-shirt
    INSERT INTO product_variants (product_id, variant_type, variant_value) VALUES
    (product_uuid, 'size', 'S'),
    (product_uuid, 'size', 'M'),
    (product_uuid, 'size', 'L'),
    (product_uuid, 'size', 'XL');

END $$;