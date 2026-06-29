// Purpose: Product data model for catalog, cart, order, and wishlist flows.
// Main callers: ProductProvider, CartProvider, WishlistProvider, ProductCard.
// Key dependencies: None.
// Main/public functions: ProductModel, ProductModel.fromJson, ProductModel.toJson.
// Side effects: None.
// API shape: { id, name, slug, description, price, stock, category_id, image_url,
//   is_active, created_at, updated_at, categories: { id, name, slug } }

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.stock,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
  });

  final String id;
  final String name;
  final num price;
  final String description;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final int stock;
  final bool isActive;
  final num rating;
  final int reviewCount;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // API returns nested 'categories' object: { id, name, slug }
    final cats = json['categories'];
    final categoryMap = cats is Map<String, dynamic>
        ? cats
        : <String, dynamic>{};

    return ProductModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      price: _asNum(json['price']),
      description: '${json['description'] ?? ''}',
      imageUrl:
          '${json['image_url'] ?? json['imageUrl'] ?? json['image'] ?? ''}',
      categoryId: '${categoryMap['id'] ?? json['category_id'] ?? ''}',
      categoryName: '${categoryMap['name'] ?? json['category_name'] ?? ''}',
      stock: _asInt(json['stock']),
      isActive: json['is_active'] == true,
      rating: _asNum(json['rating'] ?? json['average_rating']),
      reviewCount: _asInt(json['review_count'] ?? json['reviews_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'stock': stock,
      'is_active': isActive,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  static num _asNum(Object? value) {
    return value is num ? value : num.tryParse('${value ?? 0}') ?? 0;
  }

  static int _asInt(Object? value) {
    return value is int ? value : int.tryParse('${value ?? 0}') ?? 0;
  }
}
