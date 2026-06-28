// Purpose: Product catalog home page with search, category filter, sorting, and product grid.
// Main callers: SplashPage, LoginPage.
// Key dependencies: AuthProvider, ProductProvider, ProductCard, ProductDetailPage, ProfilePage.
// Main/public functions: HomePage.
// Side effects: Fetches products/categories through ProductProvider and can trigger logout.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../product/product_detail_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => productProvider.fetchProducts(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Cari produk',
                        prefixIcon: Icon(Icons.search),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: productProvider.searchProducts,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: productProvider.selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Semua'),
                              ),
                              ...productProvider.categories.map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                productProvider.filterByCategory(value ?? ''),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: productProvider.selectedSort,
                            decoration: const InputDecoration(
                              labelText: 'Urutkan',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '',
                                child: Text('Terbaru'),
                              ),
                              DropdownMenuItem(
                                value: 'price_asc',
                                child: Text('Harga naik'),
                              ),
                              DropdownMenuItem(
                                value: 'price_desc',
                                child: Text('Harga turun'),
                              ),
                            ],
                            onChanged: (value) =>
                                productProvider.sortProducts(value ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = productProvider.products[index];
                    return ProductCard(
                      product: product,
                      isWishlisted: false,
                      onWishlistTap: () {},
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
                  }, childCount: productProvider.products.length),
                ),
              ),
            if (productProvider.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
