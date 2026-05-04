class LocalDatabaseException implements Exception {
  final String message;
  const LocalDatabaseException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class SyncException implements Exception {
  final String message;
  const SyncException(this.message);
}

class OcrException implements Exception {
  final String message;
  const OcrException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}

class CurrencyException implements Exception {
  final String message;
  const CurrencyException(this.message);
}
