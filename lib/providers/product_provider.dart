// Purpose: Product catalog, detail, category, and review state provider.
// Main callers: HomePage, ProductDetailPage.
// Key dependencies: ProductService, ReviewService, ProductModel, CategoryModel, ReviewModel.
// Main/public functions: fetchProducts, loadMoreProducts, searchProducts, filterByCategory, sortProducts, fetchProductDetail, fetchCategories, fetchProductReviews, addReview.
// Side effects: Performs product and review HTTP calls through services.

import 'package:flutter/foundation.dart';

import '../core/exceptions/app_exception.dart';
import '../core/services/product_service.dart';
import '../core/services/review_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    ProductService? productService,
    ReviewService? reviewService,
  }) : _productService = productService ?? ProductService(),
       _reviewService = reviewService ?? ReviewService();

  final ProductService _productService;
  final ReviewService _reviewService;

  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  ProductModel? selectedProduct;
  List<ReviewModel> reviews = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String searchQuery = '';
  String selectedCategory = '';
  String selectedSort = 'newest';
  int currentPage = 1;
  bool hasMore = true;
  String? errorMessage;

  Future<void> fetchProducts({bool reset = true}) async {
    if (reset) {
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _productService.fetchProducts(
        search: searchQuery,
        category: selectedCategory,
        sort: selectedSort,
        page: currentPage,
      );
      products = reset ? fetched : [...products, ...fetched];
      hasMore = fetched.isNotEmpty;
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat produk.';
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoading || isLoadingMore || !hasMore) {
      return;
    }
    isLoadingMore = true;
    currentPage += 1;
    notifyListeners();
    await fetchProducts(reset: false);
  }

  Future<void> searchProducts(String query) async {
    searchQuery = query.trim();
    await fetchProducts();
  }

  Future<void> filterByCategory(String categoryId) async {
    selectedCategory = categoryId;
    await fetchProducts();
  }

  Future<void> sortProducts(String sort) async {
    selectedSort = sort;
    await fetchProducts();
  }

  Future<void> fetchProductDetail(String productId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      selectedProduct = await _productService.fetchProductDetail(productId);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat detail produk.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      categories = await _productService.fetchCategories();
      notifyListeners();
    } on AppException catch (error) {
      errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      errorMessage = 'Gagal memuat kategori.';
      notifyListeners();
    }
  }

  Future<void> fetchProductReviews(String productId) async {
    try {
      reviews = await _reviewService.fetchProductReviews(productId);
      notifyListeners();
    } on AppException catch (error) {
      errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      errorMessage = 'Gagal memuat ulasan.';
      notifyListeners();
    }
  }

  Future<bool> addReview(String productId, int rating, String comment) async {
    try {
      await _reviewService.addReview(productId, rating, comment);
      await fetchProductReviews(productId);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Gagal menambahkan ulasan.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(String productId, String reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      await fetchProductReviews(productId);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Gagal menghapus ulasan.';
      notifyListeners();
      return false;
    }
  }
}
