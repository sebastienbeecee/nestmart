/*
  # Création forcée du schéma e-commerce

  1. Nouvelles Tables
    - `categories` - Catégories principales (id, cat_name, image, color)
    - `subcategories` - Sous-catégories (id, category_id, cat_name)
    - `products` - Produits (id, product_id, subcategory_id, product_name, etc.)
    - `product_images` - Images des produits (id, product_id, image_url)
    - `product_variants` - Variantes produits (id, product_id, variant_type, variant_value)
    - `cart_items` - Articles du panier (id, user_id, product_id, quantity)
    - `reviews` - Avis clients (id, product_id, user_id, rating, review_text)

  2. Sécurité
    - Enable RLS sur toutes les tables
    - Politiques de lecture publique pour les produits
    - Politiques d'accès utilisateur pour le panier et les avis

  3. Index
    - Index sur les clés étrangères pour optimiser les performances
    - Index sur les champs de recherche fréquents
*/

-- Suppression des tables existantes si elles existent (pour forcer la recréation)
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS product_variants CASCADE;
DROP TABLE IF EXISTS product_images CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS subcategories CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- Table des catégories principales
CREATE TABLE categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cat_name text NOT NULL UNIQUE,
  image text,
  color text DEFAULT '#3bb77e',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des sous-catégories
CREATE TABLE subcategories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  cat_name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(category_id, cat_name)
);

-- Table des produits
CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id integer UNIQUE NOT NULL,
  subcategory_id uuid REFERENCES subcategories(id) ON DELETE CASCADE,
  product_name text NOT NULL,
  cat_img text,
  description text,
  brand text NOT NULL,
  price numeric(10,2) NOT NULL DEFAULT 0,
  old_price numeric(10,2),
  discount integer DEFAULT 0,
  rating numeric(2,1) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  type text, -- hot, sale, new, best
  is_featured boolean DEFAULT false,
  stock_quantity integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des images de produits
CREATE TABLE product_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  is_primary boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Table des variantes de produits (poids, RAM, taille)
CREATE TABLE product_variants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  variant_type text NOT NULL, -- 'weight', 'ram', 'size'
  variant_value text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Table des articles du panier
CREATE TABLE cart_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Table des avis clients
CREATE TABLE reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name text NOT NULL,
  rating numeric(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Activation de RLS sur toutes les tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Politiques pour les catégories (lecture publique)
CREATE POLICY "Categories are viewable by everyone"
  ON categories
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Categories can be managed by authenticated users"
  ON categories
  FOR ALL
  TO authenticated
  USING (true);

-- Politiques pour les sous-catégories (lecture publique)
CREATE POLICY "Subcategories are viewable by everyone"
  ON subcategories
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Subcategories can be managed by authenticated users"
  ON subcategories
  FOR ALL
  TO authenticated
  USING (true);

-- Politiques pour les produits (lecture publique)
CREATE POLICY "Products are viewable by everyone"
  ON products
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Products can be managed by authenticated users"
  ON products
  FOR ALL
  TO authenticated
  USING (true);

-- Politiques pour les images de produits (lecture publique)
CREATE POLICY "Product images are viewable by everyone"
  ON product_images
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Product images can be managed by authenticated users"
  ON product_images
  FOR ALL
  TO authenticated
  USING (true);

-- Politiques pour les variantes de produits (lecture publique)
CREATE POLICY "Product variants are viewable by everyone"
  ON product_variants
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Product variants can be managed by authenticated users"
  ON product_variants
  FOR ALL
  TO authenticated
  USING (true);

-- Politiques pour les articles du panier (accès utilisateur uniquement)
CREATE POLICY "Users can view their own cart items"
  ON cart_items
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cart items"
  ON cart_items
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cart items"
  ON cart_items
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cart items"
  ON cart_items
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Politiques pour les avis (lecture publique, écriture authentifiée)
CREATE POLICY "Reviews are viewable by everyone"
  ON reviews
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Authenticated users can create reviews"
  ON reviews
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews"
  ON reviews
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews"
  ON reviews
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Index pour optimiser les performances
CREATE INDEX idx_subcategories_category_id ON subcategories(category_id);
CREATE INDEX idx_products_subcategory_id ON products(subcategory_id);
CREATE INDEX idx_products_product_id ON products(product_id);
CREATE INDEX idx_products_brand ON products(brand);
CREATE INDEX idx_products_rating ON products(rating);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_product_images_product_id ON product_images(product_id);
CREATE INDEX idx_product_variants_product_id ON product_variants(product_id);
CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);

-- Insertion des données de base
INSERT INTO categories (cat_name, image, color) VALUES
('Groceries', 'https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg', '#3bb77e'),
('Electronics', 'https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg', '#fdc040'),
('Fashion', 'https://images.pexels.com/photos/996329/pexels-photo-996329.jpeg', '#f74b81');

-- Insertion des sous-catégories
DO $$
DECLARE
    groceries_id uuid;
    electronics_id uuid;
    fashion_id uuid;
    subcategory_id uuid;
    product_uuid uuid;
BEGIN
    SELECT id INTO groceries_id FROM categories WHERE cat_name = 'Groceries';
    SELECT id INTO electronics_id FROM categories WHERE cat_name = 'Electronics';
    SELECT id INTO fashion_id FROM categories WHERE cat_name = 'Fashion';

    -- Sous-catégories pour Groceries
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
    (groceries_id, 'Bread & Juice');

    -- Sous-catégories pour Electronics
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
    (electronics_id, 'Mobile Accessories');

    -- Sous-catégories pour Fashion
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
    (fashion_id, 'Perfumes');

    -- Produits d'exemple
    SELECT id INTO subcategory_id FROM subcategories WHERE cat_name = 'Milk & Dairies';
    INSERT INTO products (product_id, subcategory_id, product_name, cat_img, description, brand, price, old_price, discount, rating, type, is_featured, stock_quantity)
    VALUES (1, subcategory_id, 'Fresh Organic Milk', 'https://images.pexels.com/photos/416978/pexels-photo-416978.jpeg', 'Premium organic milk from grass-fed cows', 'Organic Valley', 4.99, 5.99, 17, 4.5, 'new', true, 50)
    RETURNING id INTO product_uuid;

    INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
    (product_uuid, 'https://images.pexels.com/photos/416978/pexels-photo-416978.jpeg', true, 1),
    (product_uuid, 'https://images.pexels.com/photos/1435735/pexels-photo-1435735.jpeg', false, 2);

    INSERT INTO product_variants (product_id, variant_type, variant_value) VALUES
    (product_uuid, 'weight', '500'),
    (product_uuid, 'weight', '1000'),
    (product_uuid, 'weight', '2000');

    -- Smartphone
    SELECT id INTO subcategory_id FROM subcategories WHERE cat_name = 'Smartphones';
    INSERT INTO products (product_id, subcategory_id, product_name, cat_img, description, brand, price, old_price, discount, rating, type, is_featured, stock_quantity)
    VALUES (2, subcategory_id, 'Premium Smartphone X1', 'https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg', 'Latest flagship smartphone with advanced features', 'TechBrand', 899.99, 999.99, 10, 4.8, 'hot', true, 25)
    RETURNING id INTO product_uuid;

    INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
    (product_uuid, 'https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg', true, 1),
    (product_uuid, 'https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg', false, 2);

    INSERT INTO product_variants (product_id, variant_type, variant_value) VALUES
    (product_uuid, 'ram', '8'),
    (product_uuid, 'ram', '12'),
    (product_uuid, 'ram', '16');

    -- T-shirt
    SELECT id INTO subcategory_id FROM subcategories WHERE cat_name = 'Men Clothing';
    INSERT INTO products (product_id, subcategory_id, product_name, cat_img, description, brand, price, old_price, discount, rating, type, is_featured, stock_quantity)
    VALUES (3, subcategory_id, 'Classic Cotton T-Shirt', 'https://images.pexels.com/photos/1020585/pexels-photo-1020585.jpeg', 'Comfortable cotton t-shirt for everyday wear', 'FashionCo', 29.99, 39.99, 25, 4.2, 'sale', false, 100)
    RETURNING id INTO product_uuid;

    INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
    (product_uuid, 'https://images.pexels.com/photos/1020585/pexels-photo-1020585.jpeg', true, 1),
    (product_uuid, 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg', false, 2);

    INSERT INTO product_variants (product_id, variant_type, variant_value) VALUES
    (product_uuid, 'size', 'S'),
    (product_uuid, 'size', 'M'),
    (product_uuid, 'size', 'L'),
    (product_uuid, 'size', 'XL');

END $$;