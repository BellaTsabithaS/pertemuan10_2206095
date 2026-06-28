// Purpose: Normalized app exception for API and local-service failures.
// Main callers: ApiService, providers.
// Key dependencies: None.
// Main/public functions: AppException.
// Side effects: None.

class AppException implements Exception {
  const AppException(
    this.message, {
    this.statusCode,
    this.isUnauthorized = false,
  });

  final String message;
  final int? statusCode;
  final bool isUnauthorized;

  @override
  String toString() => message;
}
