// Purpose: Order history page with pagination and status summary cards.
// Main callers: HomePage, OrderSuccessPage.
// Key dependencies: OrderProvider, OrderModel, OrderDetailPage, helpers/widgets.
// Main/public functions: OrderHistoryPage.
// Side effects: Fetches order history through OrderProvider and navigates to detail.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: orders.isLoading
          ? const LoadingWidget(message: 'Memuat pesanan...')
          : orders.errorMessage != null && orders.orders.isEmpty
          ? ErrorStateWidget(
              message: orders.errorMessage!,
              onRetry: orders.fetchOrders,
            )
          : orders.orders.isEmpty
          ? const EmptyStateWidget(
              title: 'Belum ada pesanan',
              message: 'Checkout dari keranjang untuk membuat pesanan.',
            )
          : RefreshIndicator(
              onRefresh: orders.fetchOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: orders.orders.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index == orders.orders.length) {
                    if (!orders.hasMore) {
                      return const SizedBox.shrink();
                    }
                    return Center(
                      child: TextButton(
                        onPressed: orders.isLoadingMore
                            ? null
                            : orders.loadMoreOrders,
                        child: orders.isLoadingMore
                            ? const CircularProgressIndicator()
                            : const Text('Muat Lagi'),
                      ),
                    );
                  }
                  final order = orders.orders[index];
                  return _OrderCard(order: order);
                },
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt == null ? '-' : formatDate(order.createdAt!);

    return Card(
      child: ListTile(
        title: Text(
          'Order #${order.displayNumber}',
          style: AppTextStyles.bodyStrong.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text('$date\n${formatRupiah(order.total)}'),
        isThreeLine: true,
        trailing: _StatusChip(status: order.status),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  OrderDetailPage(orderId: order.id, initialOrder: order),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'processing' => AppColors.statusProcessing,
      'shipped' => AppColors.statusShipped,
      'delivered' => AppColors.statusDelivered,
      'cancelled' => AppColors.statusCancelled,
      _ => AppColors.statusPending,
    };
    return Chip(
      label: Text(status),
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}
