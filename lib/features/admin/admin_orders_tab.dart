// Purpose: Redesigned admin order management tab.
// Main callers: AdminHomePage IndexedStack.
// Key dependencies: AdminProvider, OrderModel, currency/snackbar helpers, admin UI components.
// Main/public functions: AdminOrdersTab.
// Side effects: Fetches admin orders and updates order status through AdminProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';
import 'widgets/admin_components.dart';

class AdminOrdersTab extends StatelessWidget {
  const AdminOrdersTab({super.key});

  static const statuses = [
    '',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: const AdminPageHeader(
            title: 'Kelola Pesanan',
            subtitle: 'Filter status dan proses pesanan pelanggan.',
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final status = statuses[index];
              return AdminFilterChip(
                label: status.isEmpty ? 'Semua' : status,
                selected: admin.selectedStatus == status,
                onTap: () => admin.fetchOrders(status: status),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemCount: statuses.length,
          ),
        ),
        Expanded(
          child: admin.isLoading && admin.orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => admin.fetchOrders(),
                  child: admin.orders.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          children: const [
                            AdminEmptyState(message: 'Belum ada pesanan.'),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: admin.orders.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            if (index == admin.orders.length) {
                              if (!admin.hasMore) {
                                return const SizedBox.shrink();
                              }
                              return TextButton(
                                onPressed: admin.isLoadingMore
                                    ? null
                                    : admin.loadMoreOrders,
                                child: admin.isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : const Text('Muat Lagi'),
                              );
                            }
                            return _AdminOrderTile(order: admin.orders[index]);
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class _AdminOrderTile extends StatelessWidget {
  const _AdminOrderTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    return AdminSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.displayNumber}',
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              AdminStatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatRupiah(order.total),
            style: AppTextStyles.tagline.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            order.address.isEmpty ? 'Alamat belum tersedia' : order.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: order.status,
            decoration: const InputDecoration(labelText: 'Update Status'),
            items: AdminOrdersTab.statuses
                .where((status) => status.isNotEmpty)
                .map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                )
                .toList(),
            onChanged: (status) async {
              if (status == null || status == order.status) {
                return;
              }
              final success = await admin.updateOrderStatus(order.id, status);
              if (!context.mounted) {
                return;
              }
              if (success) {
                showSuccessSnackBar(context, 'Status pesanan diperbarui.');
              } else {
                showErrorSnackBar(
                  context,
                  admin.errorMessage ?? 'Gagal mengubah status.',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
