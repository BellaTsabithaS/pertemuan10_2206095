// Purpose: Product catalog home page with bottom navigation shell.
// Main callers: SplashPage, LoginPage.
// Key dependencies: AuthProvider, CartProvider, ProductProvider, WishlistProvider,
//   ProductCard, CartPage, OrderHistoryPage, ProductDetailPage, ProfilePage, WishlistPage.
// Main/public functions: HomePage.
// Side effects: Fetches products/categories, mutates wishlist, and can trigger logout.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../cart/cart_page.dart';
import '../order/order_history_page.dart';
import '../product/product_detail_page.dart';
import '../profile/profile_page.dart';
import '../wishlist/wishlist_page.dart';

// Shell widget — manages bottom nav index and renders tab bodies.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Tab pages (IndexedStack keeps them alive on tab switch).
  static const List<Widget> _tabs = [
    _CatalogView(),
    WishlistPage(),
    CartPage(),
    OrderHistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<CartProvider>().totalItems;

    return Scaffold(
      backgroundColor: context.color.canvas,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top hairline divider instead of shadow
          Divider(height: 1, color: context.color.hairline),
          NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: context.color.canvas,
              surfaceTintColor: Colors.transparent,
              indicatorColor: context.color.primary.withValues(alpha: 0.1),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return AppTextStyles.finePrint.copyWith(
                  color: isSelected ? context.color.primary : context.color.inkMuted48,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: isSelected ? context.color.primary : context.color.inkMuted48,
                  size: 22,
                );
              }),
            ),
            child: NavigationBar(
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Wishlist',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cartItems > 0,
                    label: Text('$cartItems'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cartItems > 0,
                    label: Text('$cartItems'),
                    child: const Icon(Icons.shopping_bag),
                  ),
                  label: 'Keranjang',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Pesanan',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Catalog tab — product grid with search, filter, sort. No Scaffold wrapper.
class _CatalogView extends StatefulWidget {
  const _CatalogView();

  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<_CatalogView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.fetchCategories();
      provider.fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      context.read<ProductProvider>().loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final wishlist = context.watch<WishlistProvider>();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => productProvider.fetchProducts(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // --- App bar ---
          _buildAppBar(context),

          // --- Search + filters ---
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(productProvider),
          ),

          // --- Content ---
          if (productProvider.isLoading)
            const SliverFillRemaining(
              child: LoadingWidget(message: 'Memuat produk...'),
            )
          else if (productProvider.errorMessage != null &&
              productProvider.products.isEmpty)
            SliverFillRemaining(
              child: ErrorStateWidget(
                message: productProvider.errorMessage!,
                onRetry: productProvider.fetchProducts,
              ),
            )
          else if (productProvider.products.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateWidget(
                title: 'Produk kosong',
                message: 'Coba kata kunci atau kategori lain.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = productProvider.products[index];
                    return ProductCard(
                      product: product,
                      isWishlisted: wishlist.isWishlisted(product.id),
                      onWishlistTap: () => wishlist.toggleWishlist(product),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              productId: product.id,
                              initialProduct: product,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: productProvider.products.length,
                ),
              ),
            ),

          if (productProvider.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Minimal app bar: wordmark + logout.
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: context.color.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'T',
              style: AppTextStyles.tagline.copyWith(
                color: context.color.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            TextSpan(
              text: 'oko',
              style: AppTextStyles.tagline.copyWith(
                color: context.color.ink,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.color.hairline),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: context.color.primary.withAlpha(26),
            child: Icon(Icons.person, size: 20, color: context.color.primary),
          ),
        ),
      ],
    );
  }

  // Search bar + category chips + sort compact.
  Widget _buildSearchAndFilters(ProductProvider productProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: CustomTextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: productProvider.searchProducts,
            hintText: 'Cari produk...',
            prefixIcon: Icons.search,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),

        // Category + Sort dropdowns side by side
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              // Category select
              Expanded(
                child: _FilterDropdown<String>(
                  value: productProvider.selectedCategory,
                  hint: 'Semua Kategori',
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Semua')),
                    ...productProvider.categories.map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) =>
                      productProvider.filterByCategory(val ?? ''),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Sort select
              Expanded(
                child: _FilterDropdown<String>(
                  value: productProvider.selectedSort,
                  hint: 'Urutkan',
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Harga naik'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Harga turun'),
                    ),
                  ],
                  onChanged: (val) =>
                      productProvider.sortProducts(val ?? 'newest'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),
        Divider(height: 1, color: context.color.hairline),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// Reusable styled dropdown for category and sort filters.
class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(AppRadius.sm));
    final borderSide = BorderSide(color: context.color.hairline);

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      icon: Icon(
        Icons.unfold_more,
        size: 16,
        color: context.color.inkMuted48,
      ),
      style: AppTextStyles.caption.copyWith(color: context.color.ink),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.color.canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: context.color.primary, width: 1.5),
        ),
      ),
      dropdownColor: context.color.canvas,
      items: items,
      onChanged: onChanged,
    );
  }
}
