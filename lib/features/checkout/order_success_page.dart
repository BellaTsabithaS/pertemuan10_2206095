// Purpose: Checkout success page after order creation.
// Main callers: CheckoutPage.
// Key dependencies: OrderHistoryPage.
// Main/public functions: OrderSuccessPage.
// Side effects: Navigates to order history or back to home.

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../order/order_history_page.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Berhasil')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 72),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Pesanan berhasil dibuat',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyStrong.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Cek riwayat pesanan untuk melihat status dan detail pesanan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                );
              },
              child: const Text('Lihat Riwayat'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Kembali ke Toko'),
            ),
          ],
        ),
      ),
    );
  }
}
