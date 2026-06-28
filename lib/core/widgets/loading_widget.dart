// Purpose: Shared loading indicator for pages and inline sections.
// Main callers: Auth, product, cart, order, and wishlist pages.
// Key dependencies: AppSpacing.
// Main/public functions: LoadingWidget.
// Side effects: None.

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(message!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
