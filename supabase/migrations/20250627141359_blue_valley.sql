/*
  # Schéma de base de données e-commerce

  1. Nouvelles Tables
    - `categories` - Catégories principales (Groceries, Electronics, Fashion)
    - `subcategories` - Sous-catégories (Milk & Dairies, Wines & Drinks, etc.)
    - `products` - Produits avec toutes leurs informations
    - `product_images` - Images des produits
    - `product_variants` - Variantes des produits (poids, RAM, taille)
    - `cart_items` - Articles dans le panier
    - `reviews` - Avis clients

  2. Sécurité
    - Activation de RLS sur toutes les tables
    - Politiques pour les utilisateurs authentifiés et anonymes
    - Accès en lecture publique pour les produits et catégories
    - Accès restreint pour les paniers et avis

  3. Relations
    - Clés étrangères entre toutes les tables liées
    - Index pour optimiser les performances
*/

-- Table des catégories principales
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cat_name text NOT NULL,
  image text,
  color text DEFAULT '#3bb77e',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des sous-catégories
CREATE TABLE IF NOT EXISTS subcategories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  cat_name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Table des produits
CREATE TABLE IF NOT EXISTS products (
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
CREATE TABLE IF NOT EXISTS product_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  is_primary boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Table des variantes de produits (poids, RAM, taille)
CREATE TABLE IF NOT EXISTS product_variants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  variant_type text NOT NULL, -- 'weight', 'ram', 'size'
  variant_value text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Table des articles du panier
CREATE TABLE IF NOT EXISTS cart_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Table des avis clients
CREATE TABLE IF NOT EXISTS reviews (
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
CREATE INDEX IF NOT EXISTS idx_subcategories_category_id ON subcategories(category_id);
CREATE INDEX IF NOT EXISTS idx_products_subcategory_id ON products(subcategory_id);
CREATE INDEX IF NOT EXISTS idx_products_product_id ON products(product_id);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);
CREATE INDEX IF NOT EXISTS idx_products_rating ON products(rating);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);