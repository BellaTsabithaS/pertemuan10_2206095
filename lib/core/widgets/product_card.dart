// Purpose: Shared product card for catalog and wishlist grids.
// Main callers: HomePage, WishlistPage.
// Key dependencies: CachedNetworkImage, ProductModel, currency helper, design tokens.
// Main/public functions: ProductCard.
// Side effects: Invokes tap callbacks for navigation and wishlist toggles.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../helpers/currency_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onWishlistTap,
    required this.isWishlisted,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: isWishlisted ? 'Hapus wishlist' : 'Tambah wishlist',
                  onPressed: onWishlistTap,
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? AppColors.statusCancelled : null,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: product.imageUrl.isEmpty
                      ? const Icon(Icons.image_outlined, size: 64)
                      : CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, _) =>
                              const CircularProgressIndicator(),
                          errorWidget: (_, _, _) =>
                              const Icon(Icons.broken_image_outlined, size: 64),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatRupiah(product.price),
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (product.categoryName.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    product.categoryName,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
