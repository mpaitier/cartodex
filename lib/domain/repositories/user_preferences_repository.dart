import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/accounts_sort_option.dart';

/// Frontière entre le domaine et le stockage des réglages
/// d'affichage choisis par l'utilisateur, conservés d'un lancement à
/// l'autre sur l'appareil.
///
/// Purement local : ces choix ne partent pas dans le cloud, chaque
/// appareil garde les siens.
abstract class UserPreferencesRepository {
  /// Critère de tri de la liste des comptes enregistré, ou `null` si
  /// aucun choix n'a encore été fait (ou si la valeur stockée n'est
  /// plus reconnue).
  Future<Either<Failure, AccountsSortOption?>> getAccountsSortOption();

  /// Enregistre [option] comme critère de tri de la liste des comptes.
  Future<Either<Failure, void>> saveAccountsSortOption(
    AccountsSortOption option,
  );
}
