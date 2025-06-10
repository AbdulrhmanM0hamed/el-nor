class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
} 