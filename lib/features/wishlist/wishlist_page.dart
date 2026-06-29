// Purpose: Wishlist page showing locally saved products.
// Main callers: HomePage (IndexedStack tab 1).
// Key dependencies: WishlistProvider, ProductCard, ProductDetailPage, EmptyStateWidget.
// Main/public functions: WishlistPage.
// Side effects: Loads and mutates local wishlist through WishlistProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
    final count = wishlist.wishlistProducts.length;

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
              'Wishlist',
              style: AppTextStyles.tagline.copyWith(
                color: context.color.ink,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (!wishlist.isLoading && count > 0)
              Text(
                '$count produk disimpan',
                style: AppTextStyles.finePrint.copyWith(
                  color: context.color.inkMuted48,
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.color.hairline),
        ),
      ),
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
              color: context.color.primary,
              onRefresh: wishlist.loadWishlist,
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.68,
                ),
                itemCount: count,
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
