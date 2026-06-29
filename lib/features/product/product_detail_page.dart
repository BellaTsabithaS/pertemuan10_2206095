// Purpose: Product detail, review list, and review submission page.
// Main callers: HomePage product card taps.
// Key dependencies: CartProvider, ProductProvider, ProductModel, LoadingWidget, ErrorStateWidget, currency helper.
// Main/public functions: ProductDetailPage.
// Side effects: Fetches product detail/reviews and posts reviews through ProductProvider.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

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
      final message =
          context.read<ProductProvider>().errorMessage ??
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
    final product = provider.selectedProduct ?? widget.initialProduct;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            onPressed: product == null ? null : () => _addToCart(product),
            child: const Text('Tambah ke Keranjang'),
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: product.imageUrl.isEmpty
                        ? const Icon(Icons.image_outlined, size: 96)
                        : CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, _) =>
                                const CircularProgressIndicator(),
                            errorWidget: (_, _, _) => const Icon(
                              Icons.broken_image_outlined,
                              size: 96,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(formatRupiah(product.price), style: AppTextStyles.tagline),
                const SizedBox(height: AppSpacing.sm),
                Text('Stok: ${product.stock}'),
                if (product.categoryName.isNotEmpty) Text(product.categoryName),
                const SizedBox(height: AppSpacing.lg),
                Text(product.description),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(Icons.star, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Text('${product.rating} (${product.reviewCount} ulasan)'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Tambah Ulasan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                RatingBar.builder(
                  initialRating: _rating.toDouble(),
                  minRating: 1,
                  itemCount: 5,
                  itemSize: 28,
                  itemBuilder: (_, _) => const Icon(Icons.star),
                  onRatingUpdate: (value) => _rating = value.round(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _reviewController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Ulasan'),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _submitReview,
                  child: const Text('Kirim Ulasan'),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Ulasan', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (provider.reviews.isEmpty)
                  const Text('Belum ada ulasan.')
                else
                  ...provider.reviews.map(
                    (review) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        review.userName.isEmpty ? 'User' : review.userName,
                      ),
                      subtitle: Text(
                        [
                          review.comment,
                          if (review.createdAt != null)
                            formatDate(review.createdAt!),
                        ].join('\n'),
                      ),
                      trailing: Text('${review.rating}'),
                    ),
                  ),
              ],
            ),
    );
  }
}
