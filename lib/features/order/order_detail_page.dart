// Purpose: Order detail page for status, address, notes, items, and totals.
// Main callers: OrderHistoryPage.
// Key dependencies: OrderProvider, OrderModel, helpers/widgets.
// Main/public functions: OrderDetailPage.
// Side effects: Fetches order detail through OrderProvider when opened.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
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
      appBar: AppBar(title: Text('Order #${order?.displayNumber ?? ''}')),
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
              onRefresh: () => provider.fetchOrderDetail(widget.orderId),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _InfoCard(order: order),
                  const SizedBox(height: AppSpacing.md),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(label: 'Status', value: order.status),
            _Row(label: 'Tanggal', value: date),
            _Row(
              label: 'Alamat',
              value: order.address.isEmpty ? '-' : order.address,
            ),
            _Row(
              label: 'Catatan',
              value: order.note.isEmpty ? '-' : order.note,
            ),
            const Divider(),
            _Row(
              label: 'Total',
              value: formatRupiah(order.total),
              strong: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item',
              style: AppTextStyles.bodyStrong.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (order.items.isEmpty)
              const Text('Detail item tidak tersedia.')
            else
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.product.name)),
                      Text('${item.quantity}x'),
                      const SizedBox(width: AppSpacing.sm),
                      Text(formatRupiah(item.subtotal)),
                    ],
                  ),
                ),
              ),
            const Divider(),
            _Row(label: 'Subtotal', value: formatRupiah(order.total)),
            _Row(
              label: 'Total',
              value: formatRupiah(order.total),
              strong: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? AppTextStyles.bodyStrong.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(child: Text(value, style: style)),
        ],
      ),
    );
  }
}
