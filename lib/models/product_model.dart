// Purpose: Product data model for catalog, cart, order, and wishlist flows.
// Main callers: ProductProvider, CartProvider, WishlistProvider, ProductCard.
// Key dependencies: None.
// Main/public functions: ProductModel, ProductModel.fromJson, ProductModel.toJson.
// Side effects: None.

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
  final num rating;
  final int reviewCount;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final categoryMap = category is Map<String, dynamic>
        ? category
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
