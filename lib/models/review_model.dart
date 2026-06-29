// Purpose: Review data model for product detail review lists.
// Main callers: ProductProvider, ProductDetailPage.
// Key dependencies: None.
// Main/public functions: ReviewModel, ReviewModel.fromJson.
// Side effects: None.

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final num rating;
  final String comment;
  final DateTime? createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};

    return ReviewModel(
      id: '${json['id'] ?? ''}',
      userId: '${userMap['id'] ?? json['user_id'] ?? ''}',
      userName: '${userMap['name'] ?? json['user_name'] ?? ''}',
      rating: json['rating'] is num
          ? json['rating'] as num
          : num.tryParse('${json['rating'] ?? 0}') ?? 0,
      comment: '${json['comment'] ?? json['review'] ?? ''}',
      createdAt: DateTime.tryParse(
        '${json['created_at'] ?? json['createdAt'] ?? ''}',
      ),
    );
  }
}
