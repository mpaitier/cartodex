/// Exception levée par la couche data lorsqu'un appel à l'API
/// TCGdex échoue. Interceptée par le repository et convertie en
/// [ServerFailure][../error/failures.dart] avant de remonter au domaine.
class ServerException implements Exception {
  const ServerException([this.message = 'Erreur serveur inattendue.']);

  final String message;
}

/// Exception levée par la couche data lorsqu'une opération sur la
/// base locale (Drift) échoue.
class CacheException implements Exception {
  const CacheException([this.message = 'Erreur de cache locale.']);

  final String message;
}
