// Purpose: Shared product card for catalog and wishlist grids.
// Main callers: HomePage (_CatalogView), WishlistPage.
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
    final isOutOfStock = product.stock == 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.color.canvas,
          borderRadius: AppRadius.circular(AppRadius.md),
          border: Border.all(color: context.color.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image area ---
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image
                  _ProductImage(
                    imageUrl: product.imageUrl,
                    isOutOfStock: isOutOfStock,
                  ),

                  // Wishlist button overlay (top right)
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: _WishlistButton(
                      isWishlisted: isWishlisted,
                      onTap: onWishlistTap,
                    ),
                  ),

                  // Out of stock overlay
                  if (isOutOfStock)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxs,
                        ),
                        color: context.color.ink.withValues(alpha: 0.55),
                        child: Text(
                          'Stok Habis',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.finePrint.copyWith(
                            color: context.color.onDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- Info area ---
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    if (product.categoryName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                        child: Text(
                          product.categoryName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.finePrint.copyWith(
                            color: context.color.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                    // Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: context.color.ink,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),

                    const Spacer(),

                    // Price + stock row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            formatRupiah(product.price),
                            style: AppTextStyles.captionStrong.copyWith(
                              color: context.color.ink,
                            ),
                          ),
                        ),
                        if (!isOutOfStock && product.stock <= 5)
                          Text(
                            'Sisa ${product.stock}',
                            style: AppTextStyles.finePrint.copyWith(
                              color: context.color.statusPending,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Image widget with placeholder and error fallback.
class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.isOutOfStock,
  });

  final String imageUrl;
  final bool isOutOfStock;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: isOutOfStock
          ? const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ])
          : const ColorFilter.mode(Colors.transparent, BlendMode.color),
      child: imageUrl.isEmpty
          ? Container(
              color: context.color.canvasParchment,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: context.color.inkMuted48,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: context.color.canvasParchment,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: context.color.inkMuted48,
                    ),
                  ),
                ),
              ),
              errorWidget: (_, _, _) => Container(
                color: context.color.canvasParchment,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 40,
                    color: context.color.inkMuted48,
                  ),
                ),
              ),
            ),
    );
  }
}

// Circular wishlist button with semi-transparent background.
class _WishlistButton extends StatelessWidget {
  const _WishlistButton({
    required this.isWishlisted,
    required this.onTap,
  });

  final bool isWishlisted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: context.color.canvas.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: context.color.hairline),
        ),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: isWishlisted ? context.color.statusCancelled : context.color.inkMuted48,
        ),
      ),
    );
  }
}
