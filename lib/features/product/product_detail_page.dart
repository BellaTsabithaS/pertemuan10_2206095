// Purpose: Product detail, wishlist toggle, review list, and review submission page.
// Main callers: HomePage product card taps.
// Key dependencies: CartProvider, ProductProvider, WishlistProvider, ProductModel, LoadingWidget, ErrorStateWidget, currency helper.
// Main/public functions: ProductDetailPage.
// Side effects: Fetches product detail/reviews, posts reviews, mutates cart, and mutates local wishlist.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final String productId;
  final ProductModel? initialProduct;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _reviewController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.selectedProduct = widget.initialProduct;
      provider.fetchProductDetail(widget.productId);
      provider.fetchProductReviews(widget.productId);
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      showErrorSnackBar(context, 'Ulasan wajib diisi.');
      return;
    }

    final success = await context.read<ProductProvider>().addReview(
      widget.productId,
      _rating,
      comment,
    );
    if (!mounted) {
      return;
    }
    if (success) {
      _reviewController.clear();
      showSuccessSnackBar(context, 'Ulasan berhasil ditambahkan.');
    } else {
      final message = context.read<ProductProvider>().errorMessage ??
          'Gagal menambah ulasan.';
      showErrorSnackBar(context, message);
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final cart = context.read<CartProvider>();
    final success = await cart.addToCart(product.id, 1);
    if (!mounted) {
      return;
    }
    if (success) {
      showSuccessSnackBar(context, 'Produk ditambahkan ke keranjang.');
    } else {
      showErrorSnackBar(
        context,
        cart.errorMessage ?? 'Gagal menambahkan ke keranjang.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final auth = context.watch<AuthProvider>();
    final product = provider.selectedProduct ?? widget.initialProduct;

    final isOutOfStock = product?.stock == 0;

    return Scaffold(
      backgroundColor: context.color.canvas,
      appBar: AppBar(
        backgroundColor: context.color.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.color.ink),
        title: const Text(''), // Kosong agar clean
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.color.hairline),
        ),
        actions: [
          if (product != null)
            IconButton(
              tooltip: wishlist.isWishlisted(product.id)
                  ? 'Hapus wishlist'
                  : 'Tambah wishlist',
              onPressed: () => wishlist.toggleWishlist(product),
              icon: Icon(
                wishlist.isWishlisted(product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: wishlist.isWishlisted(product.id)
                    ? context.color.statusCancelled
                    : context.color.inkMuted80,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      bottomNavigationBar: product == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.color.canvas,
                  border: Border(
                    top: BorderSide(color: context.color.hairline),
                  ),
                ),
                child: CustomButton(
                  onPressed: isOutOfStock ? null : () => _addToCart(product),
                  text: isOutOfStock ? 'Stok Habis' : 'Tambah ke Keranjang',
                ),
              ),
            ),
      body: provider.isLoading && product == null
          ? const LoadingWidget(message: 'Memuat detail produk...')
          : product == null
              ? ErrorStateWidget(
                  message: provider.errorMessage ?? 'Produk tidak ditemukan.',
                  onRetry: () => provider.fetchProductDetail(widget.productId),
                )
              : ListView(
                  children: [
                    // --- Image Section ---
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: double.infinity,
                        color: context.color.canvasParchment,
                        child: product.imageUrl.isEmpty
                            ? Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 64,
                                  color: context.color.inkMuted48,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.color.inkMuted48,
                                  ),
                                ),
                                errorWidget: (_, _, _) => Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 64,
                                    color: context.color.inkMuted48,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // --- Info Section ---
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.categoryName.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: context.color.primary.withAlpha(26),
                                borderRadius: AppRadius.circular(AppRadius.pill),
                                border: Border.all(
                                  color: context.color.primary.withAlpha(51),
                                ),
                              ),
                              child: Text(
                                product.categoryName.toUpperCase(),
                                style: AppTextStyles.finePrint.copyWith(
                                  color: context.color.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Text(
                            product.name,
                            style: AppTextStyles.tagline.copyWith(
                              color: context.color.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  formatRupiah(product.price),
                                  style: AppTextStyles.displayLarge.copyWith(
                                    color: context.color.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              if (!isOutOfStock)
                                Text(
                                  'Sisa ${product.stock}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: product.stock <= 5
                                        ? context.color.statusPending
                                        : context.color.inkMuted80,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Description
                          Text(
                            'Deskripsi Produk',
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: context.color.ink,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            product.description.isEmpty
                                ? 'Tidak ada deskripsi.'
                                : product.description,
                            style: AppTextStyles.body.copyWith(
                              color: context.color.inkMuted80,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          Divider(height: 1, color: context.color.hairline),
                          const SizedBox(height: AppSpacing.xl),

                          // Rating summary
                          Row(
                            children: [
                              Icon(Icons.star, size: 24, color: context.color.statusPending),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${product.rating}',
                                style: AppTextStyles.tagline.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.color.ink,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '(${product.reviewCount} ulasan)',
                                style: AppTextStyles.body.copyWith(
                                  color: context.color.inkMuted80,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Review Form
                          Text(
                            'Tambah Ulasan',
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: context.color.ink,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          RatingBar.builder(
                            initialRating: _rating.toDouble(),
                            minRating: 1,
                            itemCount: 5,
                            itemSize: 32,
                            unratedColor: context.color.hairline,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: context.color.statusPending,
                            ),
                            onRatingUpdate: (value) => _rating = value.round(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CustomTextField(
                            controller: _reviewController,
                            minLines: 3,
                            maxLines: 5,
                            hintText: 'Bagikan pengalaman Anda...',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _submitReview,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.color.ink,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: context.color.hairline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.circular(AppRadius.sm),
                                ),
                              ),
                              child: Text(
                                'Kirim Ulasan',
                                style: AppTextStyles.bodyStrong.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Review List
                          Text(
                            'Ulasan Pembeli',
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: context.color.ink,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (provider.reviews.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: context.color.canvasParchment,
                                borderRadius: AppRadius.circular(AppRadius.sm),
                                border: Border.all(color: context.color.hairline),
                              ),
                              child: Text(
                                'Belum ada ulasan untuk produk ini.\nJadilah yang pertama!',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body.copyWith(
                                  color: context.color.inkMuted80,
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.reviews.length,
                              separatorBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                child: Divider(height: 1, color: context.color.hairline),
                              ),
                              itemBuilder: (context, index) {
                                final review = provider.reviews[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            review.userName.isEmpty
                                                ? 'Pembeli'
                                                : review.userName,
                                            style: AppTextStyles.captionStrong.copyWith(
                                              color: context.color.ink,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (review.createdAt != null)
                                                Text(
                                                  formatDate(review.createdAt!),
                                                  style: AppTextStyles.finePrint.copyWith(
                                                    color: context.color.inkMuted48,
                                                  ),
                                                ),
                                              if (auth.user != null && review.userId == auth.user!.id) ...[
                                                const SizedBox(width: AppSpacing.sm),
                                                InkWell(
                                                  onTap: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text('Hapus Ulasan'),
                                                        content: const Text('Yakin ingin menghapus ulasan ini?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(ctx, false),
                                                            child: const Text('Batal'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(ctx, true),
                                                            child: const Text('Hapus'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      final success = await provider.deleteReview(widget.productId, review.id);
                                                      if (success && context.mounted) {
                                                        showSuccessSnackBar(context, 'Ulasan berhasil dihapus');
                                                      } else if (!success && context.mounted) {
                                                        showErrorSnackBar(context, provider.errorMessage ?? 'Gagal menghapus ulasan');
                                                      }
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 16,
                                                    color: context.color.statusCancelled,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xxs),
                                    RatingBarIndicator(
                                      rating: review.rating.toDouble(),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: context.color.statusPending,
                                      ),
                                      itemCount: 5,
                                      itemSize: 14,
                                      unratedColor: context.color.hairline,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      review.comment,
                                      style: AppTextStyles.body.copyWith(
                                        color: context.color.inkMuted80,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          const SizedBox(height: AppSpacing.xxl), // padding bawah
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
