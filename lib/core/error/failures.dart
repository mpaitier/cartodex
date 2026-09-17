import 'package:equatable/equatable.dart';

/// Représente un échec métier, retourné par les use cases sous la
/// forme d'un `Either<Failure, T>` et consommé par la couche
/// présentation. Reste indépendant de toute technologie : aucune
/// exception Dio, HTTP ou SQL ne doit franchir cette frontière.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Échec provenant d'un appel réseau (API TCGdex indisponible,
/// réponse invalide, timeout...).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Échec provenant du stockage local (base Drift inaccessible,
/// écriture échouée...).
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Échec levé quand l'appareil n'a pas de connexion réseau alors
/// qu'une synchronisation avec l'API a été demandée.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
