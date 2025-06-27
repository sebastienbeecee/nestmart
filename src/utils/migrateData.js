import { supabase } from '../lib/supabase.js';
import dbData from '../../db.json';

export const migrateDataFromJson = async () => {
  try {
    console.log('Début de la migration des données...');
    
    // Migration des catégories
    for (const category of dbData.productData) {
      const { data: categoryData, error: categoryError } = await supabase
        .from('categories')
        .upsert({
          cat_name: category.cat_name,
          image: category.image,
          color: '#3bb77e'
        }, { onConflict: 'cat_name' })
        .select()
        .single();

      if (categoryError) {
        console.error('Erreur lors de l\'insertion de la catégorie:', categoryError);
        continue;
      }

      console.log(`Catégorie créée: ${category.cat_name}`);

      // Migration des sous-catégories
      for (const subcategory of category.items) {
        const { data: subcategoryData, error: subcategoryError } = await supabase
          .from('subcategories')
          .upsert({
            category_id: categoryData.id,
            cat_name: subcategory.cat_name
          }, { onConflict: 'category_id,cat_name' })
          .select()
          .single();

        if (subcategoryError) {
          console.error('Erreur lors de l\'insertion de la sous-catégorie:', subcategoryError);
          continue;
        }

        console.log(`Sous-catégorie créée: ${subcategory.cat_name}`);

        // Migration des produits
        for (const product of subcategory.products) {
          const { data: productData, error: productError } = await supabase
            .from('products')
            .upsert({
              product_id: product.id,
              subcategory_id: subcategoryData.id,
              product_name: product.productName,
              cat_img: product.catImg,
              description: product.description,
              brand: product.brand,
              price: parseFloat(product.price.toString().replace(/,/g, '')),
              old_price: parseFloat(product.oldPrice.toString().replace(/,/g, '')),
              discount: product.discount || 0,
              rating: parseFloat(product.rating),
              type: product.type,
              is_featured: Math.random() > 0.5,
              stock_quantity: Math.floor(Math.random() * 100) + 10
            }, { onConflict: 'product_id' })
            .select()
            .single();

          if (productError) {
            console.error('Erreur lors de l\'insertion du produit:', productError);
            continue;
          }

          console.log(`Produit créé: ${product.productName}`);

          // Migration des images
          if (product.productImages && product.productImages.length > 0) {
            for (let i = 0; i < product.productImages.length; i++) {
              const { error: imageError } = await supabase
                .from('product_images')
                .upsert({
                  product_id: productData.id,
                  image_url: product.productImages[i],
                  is_primary: i === 0,
                  sort_order: i + 1
                });

              if (imageError) {
                console.error('Erreur lors de l\'insertion de l\'image:', imageError);
              }
            }
          }

          // Migration des variantes
          if (product.weight && product.weight.length > 0) {
            for (const weight of product.weight) {
              const { error: variantError } = await supabase
                .from('product_variants')
                .upsert({
                  product_id: productData.id,
                  variant_type: 'weight',
                  variant_value: weight.toString()
                });

              if (variantError) {
                console.error('Erreur lors de l\'insertion de la variante weight:', variantError);
              }
            }
          }

          if (product.RAM && product.RAM.length > 0) {
            for (const ram of product.RAM) {
              const { error: variantError } = await supabase
                .from('product_variants')
                .upsert({
                  product_id: productData.id,
                  variant_type: 'ram',
                  variant_value: ram.toString()
                });

              if (variantError) {
                console.error('Erreur lors de l\'insertion de la variante RAM:', variantError);
              }
            }
          }

          if (product.SIZE && product.SIZE.length > 0) {
            for (const size of product.SIZE) {
              const { error: variantError } = await supabase
                .from('product_variants')
                .upsert({
                  product_id: productData.id,
                  variant_type: 'size',
                  variant_value: size
                });

              if (variantError) {
                console.error('Erreur lors de l\'insertion de la variante SIZE:', variantError);
              }
            }
          }
        }
      }
    }

    console.log('Migration terminée avec succès!');
    return true;
  } catch (error) {
    console.error('Erreur lors de la migration:', error);
    return false;
  }
};