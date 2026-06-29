// Purpose: Checkout form page for creating orders from cart contents.
// Main callers: CartPage checkout action.
// Key dependencies: CartProvider, OrderProvider, NotificationService, OrderSuccessPage.
// Main/public functions: CheckoutPage.
// Side effects: Creates orders over HTTP, refreshes cart, and triggers local notification.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/snackbar_helper.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Buat pesanan?'),
            content: const Text(
              'Pastikan alamat dan isi keranjang sudah benar.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Checkout'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }

    final orders = context.read<OrderProvider>();
    final cart = context.read<CartProvider>();
    final success = await orders.checkout(
      _addressController.text.trim(),
      _noteController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (!success) {
      showErrorSnackBar(context, orders.errorMessage ?? 'Checkout gagal.');
      return;
    }

    await NotificationService.instance.showOrderSuccess();
    await cart.fetchCart();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            onPressed: orders.isLoading || cart.cartItems.isEmpty
                ? null
                : _submit,
            child: orders.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Buat Pesanan'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Ringkasan',
            style: AppTextStyles.bodyStrong.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  ...cart.cartItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(child: Text(item.product.name)),
                          Text('${item.quantity}x'),
                          const SizedBox(width: AppSpacing.sm),
                          Text(formatRupiah(item.subtotal)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(child: Text('Total')),
                      Text(
                        formatRupiah(cart.grandTotal),
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat pengiriman',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  minLines: 3,
                  maxLines: 4,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.length < 10) {
                      return 'Alamat minimal 10 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan opsional',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
