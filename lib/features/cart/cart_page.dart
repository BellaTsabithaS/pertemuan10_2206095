// Purpose: Cart page for listing cart items, editing quantities, removing items, clearing cart, and showing total.
// Main callers: HomePage cart action, product flow navigation.
// Key dependencies: CartProvider, CartItemModel, EmptyStateWidget, LoadingWidget, currency helper.
// Main/public functions: CartPage.
// Side effects: Fetches and mutates cart data through CartProvider.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';

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
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ya'),
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
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          if (cart.cartItems.isNotEmpty)
            TextButton(
              onPressed: cart.isUpdating ? null : _clearCart,
              child: const Text('Kosongkan'),
            ),
        ],
      ),
      bottomNavigationBar: cart.cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: AppTextStyles.caption),
                          Text(
                            formatRupiah(cart.grandTotal),
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: cart.isUpdating
                          ? null
                          : () {
                              showInfoSnackBar(
                                context,
                                'Checkout akan tersedia di module berikutnya.',
                              );
                            },
                      child: const Text('Checkout'),
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
                        : () => cart.updateQuantity(item.id, item.quantity - 1),
                    onIncrease: () =>
                        cart.updateQuantity(item.id, item.quantity + 1),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: item.product.imageUrl.isEmpty
                  ? const Icon(Icons.image_outlined, size: 48)
                  : CachedNetworkImage(
                      imageUrl: item.product.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const CircularProgressIndicator(),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined, size: 48),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(formatRupiah(item.product.price)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Kurangi',
                        onPressed: isUpdating ? null : onDecrease,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        tooltip: 'Tambah',
                        onPressed: isUpdating ? null : onIncrease,
                        icon: const Icon(Icons.add),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: isUpdating ? null : onRemove,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  Text('Subtotal ${formatRupiah(item.subtotal)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
