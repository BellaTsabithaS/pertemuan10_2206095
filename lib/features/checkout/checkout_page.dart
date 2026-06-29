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
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
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

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.canvas,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.circular(AppRadius.md),
              side: const BorderSide(color: AppColors.hairline),
            ),
            title: Text('Buat pesanan?', style: AppTextStyles.bodyStrong),
            content: Text(
              'Pastikan alamat dan isi keranjang sudah benar.',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.inkMuted80,
                ),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
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

  InputDecoration _shadInput(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.inkMuted80,
        fontSize: 15,
      ),
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: AppColors.inkMuted48)
          : null,
      filled: true,
      fillColor: AppColors.canvasParchment,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorStyle: AppTextStyles.finePrint.copyWith(
        color: AppColors.statusCancelled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: Text(
          'Checkout',
          style: AppTextStyles.tagline.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.hairline),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.canvas,
            border: Border(
              top: BorderSide(color: AppColors.hairline),
            ),
          ),
          child: FilledButton(
            onPressed:
                orders.isLoading || cart.cartItems.isEmpty ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.inkMuted48,
              disabledForegroundColor: AppColors.canvas,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.circular(AppRadius.sm),
              ),
              elevation: 0,
            ),
            child: orders.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.canvas,
                    ),
                  )
                : Text(
                    'Buat Pesanan',
                    style: AppTextStyles.bodyStrong.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Order Summary Section
          Text(
            'Ringkasan',
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: AppRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              children: [
                ...cart.cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.quantity}x',
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.inkMuted80,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          formatRupiah(item.subtotal),
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Divider(height: 1, color: AppColors.hairline),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total',
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(cart.grandTotal),
                      style: AppTextStyles.tagline.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),

          // Forms Section
          Text(
            'Pengiriman',
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _addressController,
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                  decoration: _shadInput(
                    'Alamat pengiriman',
                    icon: Icons.location_on_outlined,
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
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                  decoration: _shadInput(
                    'Catatan (opsional)',
                    icon: Icons.notes_outlined,
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
