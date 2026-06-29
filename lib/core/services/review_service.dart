// Purpose: Review REST service for product detail review flows.
// Main callers: ProductProvider.
// Key dependencies: ApiService, ReviewModel.
// Main/public functions: fetchProductReviews, addReview.
// Side effects: Performs HTTP requests through ApiService.

import '../../models/review_model.dart';
import 'api_service.dart';

class ReviewService {
  ReviewService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<ReviewModel>> fetchProductReviews(String productId) async {
    final response = await _api.get('/reviews/product/$productId');
    return _extractList(response).map(ReviewModel.fromJson).toList();
  }

  Future<void> addReview(String productId, int rating, String comment) async {
    await _api.post(
      '/reviews/product/$productId',
      body: {'rating': rating, 'comment': comment},
    );
  }

  Future<void> deleteReview(String reviewId) async {
    await _api.delete('/reviews/$reviewId');
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (response['reviews'] is List) {
        return (response['reviews'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }
    return <Map<String, dynamic>>[];
  }
}
