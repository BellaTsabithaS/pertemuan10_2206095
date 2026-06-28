// Purpose: Currency formatting helpers for product, cart, and order prices.
// Main callers: ProductCard, ProductDetailPage, CartPage, CheckoutPage, Order pages.
// Key dependencies: intl NumberFormat.
// Main/public functions: formatRupiah.
// Side effects: None.

import 'package:intl/intl.dart';

String formatRupiah(num value) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(value);
}
