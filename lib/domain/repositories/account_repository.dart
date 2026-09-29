import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/account.dart';

/// Frontière entre le domaine et la donnée pour la gestion des
/// comptes suivis par l'application. Purement local : contrairement
/// au référentiel de cartes, il n'y a ici aucune source distante
/// (la synchronisation cloud passe par `CloudSyncRepository`).
abstract class AccountRepository {
  /// Retourne tous les comptes, dans leur ordre de création.
  Future<Either<Failure, List<Account>>> getAccounts();

  /// Crée un compte. Le tout premier compte créé devient
  /// automatiquement principal ; tout compte créé ensuite est
  /// secondaire.
  Future<Either<Failure, void>> addAccount({
    required String name,
    required String gameAccountId,
  });

  /// Fait de [accountId] le nouveau compte principal. L'ancien
  /// principal redevient secondaire : il y en a toujours exactement
  /// un (dès qu'au moins un compte existe).
  Future<Either<Failure, void>> setPrimaryAccount(String accountId);

  /// Remplace par de vrais UUID les identifiants hérités d'avant la
  /// synchronisation (simples nombres en texte, ex: "1"), et
  /// réattache la possession correspondante. À faire avant tout
  /// envoi dans le cloud : deux appareils peuvent chacun avoir un
  /// compte "1". Sans effet s'il n'y en a plus.
  Future<Either<Failure, void>> migrateLegacyAccountIds();

  /// Ajoute en local un compte venu du cloud, avec son identifiant
  /// d'origine. Sans effet si un compte de même id existe déjà.
  /// Devient principal seulement s'il n'y avait aucun compte.
  Future<Either<Failure, void>> importAccount({
    required String id,
    required String name,
    required String gameAccountId,
    required DateTime createdAt,
  });
}