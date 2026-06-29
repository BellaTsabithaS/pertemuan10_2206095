// Purpose: Order history page with pagination and status summary cards.
// Main callers: HomePage (IndexedStack tab 3), OrderSuccessPage.
// Key dependencies: OrderProvider, OrderModel, OrderDetailPage, helpers/widgets.
// Main/public functions: OrderHistoryPage.
// Side effects: Fetches order history through OrderProvider and navigates to detail.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import 'order_detail_page.dart';

class OrderHistoryPage
    extends
        StatefulWidget {
  const OrderHistoryPage({
    super.key,
  });

  @override
  State<
    OrderHistoryPage
  >
  createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState
    extends
        State<
          OrderHistoryPage
        > {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) {
        context
            .read<
              OrderProvider
            >()
            .fetchOrders();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final orders = context
        .watch<
          OrderProvider
        >();

    return Scaffold(
      backgroundColor: context.color.canvas,
      appBar: AppBar(
        backgroundColor: context.color.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan',
              style: AppTextStyles.tagline.copyWith(
                color: context.color.ink,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (!orders.isLoading &&
                orders.orders.isNotEmpty)
              Text(
                '${orders.orders.length} transaksi',
                style: AppTextStyles.finePrint.copyWith(
                  color: context.color.inkMuted48,
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            1,
          ),
          child: Divider(
            height: 1,
            color: context.color.hairline,
          ),
        ),
      ),
      body: orders.isLoading
          ? const LoadingWidget(
              message: 'Memuat pesanan...',
            )
          : orders.errorMessage !=
                    null &&
                orders.orders.isEmpty
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
              color: context.color.primary,
              onRefresh: orders.fetchOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                itemCount: orders.orders.length,
                separatorBuilder:
                    (
                      _,
                      _,
                    ) => const SizedBox(
                      height: AppSpacing.md,
                    ),
                itemBuilder: (context, index) {
                  final order = orders.orders[index];
                  return _OrderCard(order: order);
                },
              ),
            ),
    );
  }
}

class _OrderCard
    extends
        StatelessWidget {
  const _OrderCard({
    required this.order,
  });

  final OrderModel order;

  @override
  Widget build(
    BuildContext context,
  ) {
    final date =
        order.createdAt ==
            null
        ? '-'
        : formatDate(
            order.createdAt!,
          );

    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(
          MaterialPageRoute(
            builder:
                (
                  _,
                ) => OrderDetailPage(
                  orderId: order.id,
                  initialOrder: order,
                ),
          ),
        );
      },
      borderRadius: AppRadius.circular(
        AppRadius.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.color.canvas,
          borderRadius: AppRadius.circular(
            AppRadius.sm,
          ),
          border: Border.all(
            color: context.color.hairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.displayNumber}',
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: context.color.ink,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusBadge(
                  status: order.status,
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            Text(
              date,
              style: AppTextStyles.caption.copyWith(
                color: context.color.inkMuted48,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              child: Divider(
                height: 1,
                color: context.color.hairline,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pesanan',
                  style: AppTextStyles.caption.copyWith(
                    color: context.color.inkMuted80,
                  ),
                ),
                Text(
                  formatRupiah(
                    order.total,
                  ),
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: context.color.ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge
    extends
        StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(
    BuildContext context,
  ) {
    final color = switch (status.toLowerCase()) {
      'processing' => context.color.statusProcessing,
      'shipped' => context.color.statusShipped,
      'delivered' => context.color.statusDelivered,
      'cancelled' => context.color.statusCancelled,
      _ => context.color.statusPending,
    };

    final statusText = switch (status.toLowerCase()) {
      'pending' => 'Pending',
      'processing' => 'Diproses',
      'shipped' => 'Dikirim',
      'delivered' => 'Selesai',
      'cancelled' => 'Dibatalkan',
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(
          20,
        ),
        borderRadius: AppRadius.circular(
          AppRadius.pill,
        ),
        border: Border.all(
          color: color.withAlpha(
            51,
          ),
        ),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: AppTextStyles.finePrint.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
