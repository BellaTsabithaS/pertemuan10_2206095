// Purpose: Order detail page for status, address, notes, items, and totals.
// Main callers: OrderHistoryPage.
// Key dependencies: OrderProvider, OrderModel, helpers/widgets.
// Main/public functions: OrderDetailPage.
// Side effects: Fetches order detail through OrderProvider when opened.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId, this.initialOrder});

  final String orderId;
  final OrderModel? initialOrder;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.selectedOrder?.id == widget.orderId
        ? provider.selectedOrder
        : widget.initialOrder;

    return Scaffold(
      backgroundColor: context.color.canvas,
      appBar: AppBar(
        backgroundColor: context.color.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.color.ink),
        title: Text(
          'Order #${order?.displayNumber ?? ''}',
          style: AppTextStyles.tagline.copyWith(
            color: context.color.ink,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: context.color.hairline),
        ),
      ),
      body: provider.isLoading && order == null
          ? const LoadingWidget(message: 'Memuat detail pesanan...')
          : provider.errorMessage != null && order == null
              ? ErrorStateWidget(
                  message: provider.errorMessage!,
                  onRetry: () => provider.fetchOrderDetail(widget.orderId),
                )
              : order == null
                  ? const Center(child: Text('Pesanan tidak ditemukan.'))
                  : RefreshIndicator(
                      color: context.color.primary,
                      onRefresh: () => provider.fetchOrderDetail(widget.orderId),
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          _InfoCard(order: order),
                          const SizedBox(height: AppSpacing.lg),
                          _ItemsCard(order: order),
                        ],
                      ),
                    ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt == null ? '-' : formatDate(order.createdAt!);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.color.canvas,
        borderRadius: AppRadius.circular(AppRadius.sm),
        border: Border.all(color: context.color.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(
            label: 'Status',
            valueWidget: _StatusBadge(status: order.status),
          ),
          _Row(label: 'Tanggal', value: date),
          _Row(
            label: 'Alamat',
            value: order.address.isEmpty ? '-' : order.address,
          ),
          _Row(
            label: 'Catatan',
            value: order.note.isEmpty ? '-' : order.note,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Divider(height: 1, color: context.color.hairline),
          ),
          _Row(
            label: 'Total',
            value: formatRupiah(order.total),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.color.canvas,
        borderRadius: AppRadius.circular(AppRadius.sm),
        border: Border.all(color: context.color.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Item',
            style: AppTextStyles.bodyStrong.copyWith(
              color: context.color.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (order.items.isEmpty)
            Text(
              'Detail item tidak tersedia.',
              style: AppTextStyles.body.copyWith(color: AppColors.inkMuted80),
            )
          else
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: context.color.ink,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: AppTextStyles.body.copyWith(
                          color: context.color.inkMuted80,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      formatRupiah(item.subtotal),
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: context.color.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Divider(height: 1, color: context.color.hairline),
          ),
          _Row(label: 'Subtotal', value: formatRupiah(order.total)),
          _Row(
            label: 'Total Belanja',
            value: formatRupiah(order.total),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    this.value,
    this.valueWidget,
    this.strong = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final textStyle = strong
        ? AppTextStyles.bodyStrong.copyWith(color: context.color.ink)
        : AppTextStyles.body.copyWith(color: context.color.inkMuted80);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: AppColors.ink),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '',
                  style: textStyle,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
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
        color: color.withAlpha(20),
        borderRadius: AppRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withAlpha(51)),
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
