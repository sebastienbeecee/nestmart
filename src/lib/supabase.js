import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Fonctions utilitaires pour les données
export const getCategories = async () => {
  const { data, error } = await supabase
    .from('categories')
    .select(`
      *,
      subcategories (
        *,
        products (
          *,
          product_images (*),
          product_variants (*)
        )
      )
    `)
    .order('created_at')
  
  if (error) {
    console.error('Erreur lors de la récupération des catégories:', error)
    return []
  }
  
  return data
}

export const getProducts = async (filters = {}) => {
  let query = supabase
    .from('products')
    .select(`
      *,
      subcategories (
        *,
        categories (*)
      ),
      product_images (*),
      product_variants (*)
    `)
  
  if (filters.subcategoryId) {
    query = query.eq('subcategory_id', filters.subcategoryId)
  }
  
  if (filters.brand) {
    query = query.eq('brand', filters.brand)
  }
  
  if (filters.minPrice && filters.maxPrice) {
    query = query.gte('price', filters.minPrice).lte('price', filters.maxPrice)
  }
  
  if (filters.rating) {
    query = query.gte('rating', filters.rating)
  }
  
  const { data, error } = await query.order('created_at', { ascending: false })
  
  if (error) {
    console.error('Erreur lors de la récupération des produits:', error)
    return []
  }
  
  return data
}

export const getProductById = async (productId) => {
  const { data, error } = await supabase
    .from('products')
    .select(`
      *,
      subcategories (
        *,
        categories (*)
      ),
      product_images (*),
      product_variants (*),
      reviews (
        *,
        user_id
      )
    `)
    .eq('product_id', productId)
    .single()
  
  if (error) {
    console.error('Erreur lors de la récupération du produit:', error)
    return null
  }
  
  return data
}

export const addToCart = async (userId, productId, quantity = 1) => {
  const { data, error } = await supabase
    .from('cart_items')
    .upsert({
      user_id: userId,
      product_id: productId,
      quantity: quantity
    }, {
      onConflict: 'user_id,product_id'
    })
  
  if (error) {
    console.error('Erreur lors de l\'ajout au panier:', error)
    return false
  }
  
  return true
}

export const getCartItems = async (userId) => {
  const { data, error } = await supabase
    .from('cart_items')
    .select(`
      *,
      products (
        *,
        product_images (*)
      )
    `)
    .eq('user_id', userId)
  
  if (error) {
    console.error('Erreur lors de la récupération du panier:', error)
    return []
  }
  
  return data
}

export const removeFromCart = async (userId, productId) => {
  const { error } = await supabase
    .from('cart_items')
    .delete()
    .eq('user_id', userId)
    .eq('product_id', productId)
  
  if (error) {
    console.error('Erreur lors de la suppression du panier:', error)
    return false
  }
  
  return true
}

export const addReview = async (productId, userId, userName, rating, reviewText) => {
  const { data, error } = await supabase
    .from('reviews')
    .insert({
      product_id: productId,
      user_id: userId,
      user_name: userName,
      rating: rating,
      review_text: reviewText
    })
  
  if (error) {
    console.error('Erreur lors de l\'ajout de l\'avis:', error)
    return false
  }
  
  return true
}