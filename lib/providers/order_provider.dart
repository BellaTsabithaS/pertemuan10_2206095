// Purpose: Order state provider for checkout, history pagination, and detail.
// Main callers: CheckoutPage, OrderHistoryPage, OrderDetailPage.
// Key dependencies: ChangeNotifier, OrderService, OrderModel, AppException.
// Main/public functions: checkout, fetchOrders, loadMoreOrders, fetchOrderDetail.
// Side effects: Performs order HTTP calls through OrderService.

import 'package:flutter/foundation.dart';

import '../core/exceptions/app_exception.dart';
import '../core/services/order_service.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderService? orderService})
    : _orderService = orderService ?? OrderService();

  final OrderService _orderService;

  List<OrderModel> orders = [];
  OrderModel? selectedOrder;
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;
  String? errorMessage;

  Future<bool> checkout(String address, String note) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      selectedOrder = await _orderService.checkout(address, note);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Gagal membuat pesanan.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders({bool reset = true}) async {
    if (reset) {
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _orderService.fetchOrders(page: currentPage);
      orders = reset ? fetched : [...orders, ...fetched];
      hasMore = fetched.isNotEmpty;
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat pesanan.';
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

  Future<void> fetchOrderDetail(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      selectedOrder = await _orderService.fetchOrderDetail(id);
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat detail pesanan.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
