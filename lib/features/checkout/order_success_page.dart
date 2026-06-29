// Purpose: Checkout success page after order creation.
// Main callers: CheckoutPage.
// Key dependencies: OrderHistoryPage.
// Main/public functions: OrderSuccessPage.
// Side effects: Navigates to order history or back to home.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../order/order_history_page.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // Prevent back navigation manually
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              const Icon(
                Icons.check_circle,
                size: 96,
                color: AppColors.statusDelivered,
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Text
              Text(
                'Pesanan Berhasil!',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.ink,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Terima kasih telah berbelanja.\nCek riwayat pesanan untuk melihat status dan detail.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.inkMuted80,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),

              // Actions
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.circular(AppRadius.sm),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Lihat Riwayat Pesanan',
                  style: AppTextStyles.bodyStrong.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.inkMuted80,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: AppTextStyles.bodyStrong.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
