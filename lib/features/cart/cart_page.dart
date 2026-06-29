// Purpose: Cart page for listing cart items, editing quantities, removing items, clearing cart, total, and checkout navigation.
// Main callers: HomePage (IndexedStack tab 2), product flow navigation.
// Key dependencies: CartProvider, CartItemModel, CheckoutPage, EmptyStateWidget, LoadingWidget, currency helper.
// Main/public functions: CartPage.
// Side effects: Fetches and mutates cart data through CartProvider and navigates to checkout.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  Future<void> _removeItem(CartItemModel item) async {
    final confirmed = await _confirm(
      title: 'Hapus item?',
      message: 'Produk ${item.product.name} akan dihapus dari keranjang.',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final cart = context.read<CartProvider>();
    final success = await cart.removeItem(item.id);
    if (!mounted) {
      return;
    }
    if (!success) {
      showErrorSnackBar(context, cart.errorMessage ?? 'Gagal menghapus item.');
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await _confirm(
      title: 'Kosongkan keranjang?',
      message: 'Semua item akan dihapus dari keranjang.',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final cart = context.read<CartProvider>();
    final success = await cart.clearCart();
    if (!mounted) {
      return;
    }
    if (!success) {
      showErrorSnackBar(
        context,
        cart.errorMessage ?? 'Gagal mengosongkan keranjang.',
      );
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: context.color.canvas,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.circular(AppRadius.md),
              side: BorderSide(color: context.color.hairline),
            ),
            title: Text(title, style: AppTextStyles.bodyStrong),
            content: Text(message, style: AppTextStyles.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: context.color.inkMuted80),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: context.color.statusCancelled,
                  foregroundColor: context.color.onDark,
                ),
                child: const Text('Ya, Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

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
              'Keranjang',
              style: AppTextStyles.tagline.copyWith(
                color: context.color.ink,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (!cart.isLoading && cart.totalItems > 0)
              Text(
                '${cart.totalItems} barang',
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
        actions: [
          if (cart.cartItems.isNotEmpty)
            TextButton(
              onPressed: cart.isUpdating ? null : _clearCart,
              style: TextButton.styleFrom(
                foregroundColor: context.color.statusCancelled,
              ),
              child: Text(
                'Kosongkan',
                style: AppTextStyles.captionStrong,
              ),
            ),
        ],
      ),
      bottomNavigationBar: cart.cartItems.isEmpty
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Belanja', style: AppTextStyles.caption),
                          Text(
                            formatRupiah(cart.grandTotal),
                            style: AppTextStyles.tagline.copyWith(
                              color: context.color.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: cart.isUpdating
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutPage(),
                                ),
                              );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: context.color.primary,
                        foregroundColor: context.color.onPrimary,
                        disabledBackgroundColor: context.color.inkMuted48,
                        disabledForegroundColor: context.color.canvas,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.circular(AppRadius.sm),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Checkout',
                        style: AppTextStyles.bodyStrong.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.color.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: cart.isLoading
          ? const LoadingWidget(message: 'Memuat keranjang...')
          : cart.errorMessage != null && cart.cartItems.isEmpty
              ? ErrorStateWidget(
                  message: cart.errorMessage!,
                  onRetry: cart.fetchCart,
                )
              : cart.cartItems.isEmpty
                  ? const EmptyStateWidget(
                      title: 'Keranjang kosong',
                      message: 'Tambahkan produk dulu dari katalog.',
                    )
                  : RefreshIndicator(
                      color: context.color.primary,
                      onRefresh: cart.fetchCart,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: cart.cartItems.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final item = cart.cartItems[index];
                          return _CartItemTile(
                            item: item,
                            isUpdating: cart.isUpdating,
                            onDecrease: item.quantity <= 1
                                ? null
                                : () => cart.updateQuantity(
                                      item.id,
                                      item.quantity - 1,
                                    ),
                            onIncrease: () => cart.updateQuantity(
                              item.id,
                              item.quantity + 1,
                            ),
                            onRemove: () => _removeItem(item),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.isUpdating,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final bool isUpdating;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.canvas,
        borderRadius: AppRadius.circular(AppRadius.sm),
        border: Border.all(color: context.color.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Container(
            width: 100,
            height: 100,
            color: context.color.canvasParchment,
            child: item.product.imageUrl.isEmpty
                ? Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: context.color.inkMuted48,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: item.product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: context.color.inkMuted48,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 32,
                        color: context.color.inkMuted48,
                      ),
                    ),
                  ),
          ),
          
          // Info Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: context.color.ink,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: isUpdating ? null : onRemove,
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: isUpdating
                              ? context.color.inkMuted48
                              : context.color.statusCancelled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    formatRupiah(item.product.price),
                    style: AppTextStyles.caption.copyWith(
                      color: context.color.inkMuted80,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Controls and Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: context.color.hairline),
                          borderRadius: AppRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onTap: isUpdating ? null : onDecrease,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              constraints: const BoxConstraints(minWidth: 32),
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: AppTextStyles.captionStrong.copyWith(
                                  color: context.color.ink,
                                ),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onTap: isUpdating ? null : onIncrease,
                            ),
                          ],
                        ),
                      ),
                      
                      // Subtotal
                      Text(
                        formatRupiah(item.subtotal),
                        style: AppTextStyles.captionStrong.copyWith(
                          color: context.color.primary,
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
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? AppColors.inkMuted48 : AppColors.ink,
        ),
      ),
    );
  }
}
