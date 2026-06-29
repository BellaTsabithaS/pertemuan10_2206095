// Purpose: Wishlist page showing locally saved products.
// Main callers: HomePage wishlist action.
// Key dependencies: WishlistProvider, ProductCard, ProductDetailPage, EmptyStateWidget.
// Main/public functions: WishlistPage.
// Side effects: Loads and mutates local wishlist through WishlistProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/wishlist_provider.dart';
import '../product/product_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlist.isLoading
          ? const LoadingWidget(message: 'Memuat wishlist...')
          : wishlist.wishlistProducts.isEmpty
          ? EmptyStateWidget(
              title: 'Wishlist kosong',
              message: 'Simpan produk favorit dari katalog.',
              actionLabel: 'Lihat Produk',
              onAction: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            )
          : RefreshIndicator(
              onRefresh: wishlist.loadWishlist,
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.68,
                ),
                itemCount: wishlist.wishlistProducts.length,
                itemBuilder: (context, index) {
                  final product = wishlist.wishlistProducts[index];
                  return ProductCard(
                    product: product,
                    isWishlisted: true,
                    onWishlistTap: () => wishlist.removeWishlist(product.id),
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
              ),
            ),
    );
  }
}
