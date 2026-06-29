// Purpose: Admin state provider for dashboard, admin order management, category CRUD, and product CRUD.
// Main callers: AdminHomePage.
// Key dependencies: ChangeNotifier, AdminService, OrderModel, CategoryModel, ProductModel, AppException.
// Main/public functions: loadDashboard, fetchOrders, loadMoreOrders, fetchCategories, updateOrderStatus, createCategory, updateCategory, deleteCategory, fetchProducts, createProduct, updateProduct, deleteProduct.
// Side effects: Performs admin HTTP calls through AdminService.

import 'package:flutter/foundation.dart';

import '../core/exceptions/app_exception.dart';
import '../core/services/admin_service.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({AdminService? adminService})
    : _adminService = adminService ?? AdminService();

  final AdminService _adminService;

  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> lowStock = [];
  List<Map<String, dynamic>> topProducts = [];
  List<Map<String, dynamic>> recentOrders = [];
  List<OrderModel> orders = [];
  List<CategoryModel> categories = [];
  List<ProductModel> products = [];
  String selectedStatus = '';
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      stats = await _adminService.fetchStats();
      lowStock = await _adminService.fetchLowStock();
      topProducts = await _adminService.fetchTopProducts();
      recentOrders = await _adminService.fetchRecentOrders();
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat dashboard admin.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      categories = await _adminService.fetchCategories();
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat kategori.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      products = await _adminService.fetchProducts();
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat produk.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders({String? status, bool reset = true}) async {
    if (status != null) {
      selectedStatus = status;
    }
    if (reset) {
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _adminService.fetchOrders(
        status: selectedStatus,
        page: currentPage,
      );
      orders = reset ? fetched : [...orders, ...fetched];
      hasMore = fetched.isNotEmpty;
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat pesanan admin.';
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreOrders() async {
    if (isLoading || isLoadingMore || !hasMore) {
      return;
    }
    isLoadingMore = true;
    currentPage += 1;
    notifyListeners();
    await fetchOrders(reset: false);
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final updated = await _adminService.updateOrderStatus(orderId, status);
      orders = orders
          .map((order) => order.id == orderId ? updated : order)
          .toList();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Gagal mengubah status pesanan.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<CategoryModel?> createCategory({
    required String name,
    String description = '',
    String imageUrl = '',
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final category = await _adminService.createCategory(
        name: name,
        description: description,
        imageUrl: imageUrl,
      );
      categories = [
        ...categories.where((item) => item.id != category.id),
        category,
      ];
      return category;
    } on AppException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Gagal menambah kategori.';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<CategoryModel?> updateCategory({
    required String id,
    required String name,
    String description = '',
    String imageUrl = '',
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final category = await _adminService.updateCategory(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
      );
      categories = categories
          .map((item) => item.id == id ? category : item)
          .toList();
      return category;
    } on AppException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Gagal mengubah kategori.';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String id) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _adminService.deleteCategory(id);
      categories = categories.where((item) => item.id != id).toList();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Gagal menghapus kategori.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> createProduct({
    required String name,
    required num price,
    required int stock,
    required String categoryId,
    String description = '',
    String imageUrl = '',
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final product = await _adminService.createProduct(
        name: name,
        price: price,
        stock: stock,
        categoryId: categoryId,
        description: description,
        imageUrl: imageUrl,
      );
      products = [...products.where((item) => item.id != product.id), product];
      return product;
    } on AppException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Gagal menambah produk.';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> updateProduct({
    required String id,
    required String name,
    required num price,
    required int stock,
    required String categoryId,
    required bool isActive,
    String description = '',
    String imageUrl = '',
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final product = await _adminService.updateProduct(
        id: id,
        name: name,
        price: price,
        stock: stock,
        categoryId: categoryId,
        isActive: isActive,
        description: description,
        imageUrl: imageUrl,
      );
      products = products
          .map((item) => item.id == id ? product : item)
          .toList();
      return product;
    } on AppException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Gagal mengubah produk.';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _adminService.deleteProduct(id);
      products = products.where((item) => item.id != id).toList();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Gagal menghapus produk.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
