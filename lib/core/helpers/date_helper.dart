// Purpose: Date formatting helpers for order history and detail.
// Main callers: OrderHistoryPage, OrderDetailPage.
// Key dependencies: intl DateFormat.
// Main/public functions: formatDate.
// Side effects: None.

import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
}
