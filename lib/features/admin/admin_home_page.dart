// Purpose: Admin mobile shell with bottom navigation for dashboard, orders, categories, and products.
// Main callers: LoginPage and SplashPage when authenticated user has admin role.
// Key dependencies: AdminProvider, AuthProvider, admin tab widgets, design-token themed NavigationBar.
// Main/public functions: AdminHomePage.
// Side effects: Preloads admin dashboard/orders/categories/products, changes local navigation index, and can logout.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_category_tab.dart';
import 'admin_dashboard_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_product_tab.dart';
import 'widgets/admin_components.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  static const _titles = ['Dashboard', 'Pesanan', 'Kategori', 'Produk'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      admin.loadDashboard();
      admin.fetchOrders();
      admin.fetchCategories();
      admin.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin'),
            Text(
              _titles[_selectedIndex],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AdminIconAction(
              tooltip: 'Logout',
              onPressed: () => context.read<AuthProvider>().logout(),
              icon: Icons.logout,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AdminDashboardTab(),
          AdminOrdersTab(),
          AdminCategoryTab(),
          AdminProductTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Kategori',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
        ],
      ),
    );
  }
}
