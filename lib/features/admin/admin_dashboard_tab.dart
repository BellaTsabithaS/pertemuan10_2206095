// Purpose: Redesigned admin dashboard tab with summary metrics and compact activity lists.
// Main callers: AdminHomePage IndexedStack.
// Key dependencies: AdminProvider, currency helper, admin UI components.
// Main/public functions: AdminDashboardTab.
// Side effects: Refreshes dashboard data through AdminProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/admin_provider.dart';
import 'widgets/admin_components.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    if (admin.isLoading && admin.stats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final stats = admin.stats;

    return RefreshIndicator(
      onRefresh: admin.loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AdminPageHeader(
            title: 'Ringkasan Toko',
            subtitle: 'Pantau performa utama dan aktivitas terbaru.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                AdminMetricTile(
                  label: 'Revenue',
                  value: formatRupiah(_asNum(stats['total_revenue'])),
                  icon: Icons.payments_outlined,
                ),
                const SizedBox(width: AppSpacing.md),
                AdminMetricTile(
                  label: 'Produk',
                  value: '${stats['total_products'] ?? 0}',
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(width: AppSpacing.md),
                AdminMetricTile(
                  label: 'Pesanan',
                  value: '${stats['total_orders'] ?? 0}',
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(width: AppSpacing.md),
                AdminMetricTile(
                  label: 'User',
                  value: '${stats['total_users'] ?? 0}',
                  icon: Icons.people_alt_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MapSection(title: 'Stok Menipis', items: admin.lowStock),
          const SizedBox(height: AppSpacing.md),
          _MapSection(title: 'Produk Terlaris', items: admin.topProducts),
          const SizedBox(height: AppSpacing.md),
          _MapSection(title: 'Pesanan Terbaru', items: admin.recentOrders),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({required this.title, required this.items});

  final String title;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      title: title,
      child: items.isEmpty
          ? const AdminEmptyState(message: 'Belum ada data.')
          : Column(
              children: items.take(5).map((item) {
                final name =
                    item['name'] ??
                    item['product_name'] ??
                    item['customer_name'] ??
                    item['email'] ??
                    item['id'] ??
                    '-';
                final trailing =
                    item['stock'] ??
                    item['total_sold'] ??
                    item['status'] ??
                    item['total'] ??
                    '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.captionStrong,
                        ),
                      ),
                      Text('$trailing', style: AppTextStyles.caption),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

num _asNum(Object? value) {
  return value is num ? value : num.tryParse('${value ?? 0}') ?? 0;
}
