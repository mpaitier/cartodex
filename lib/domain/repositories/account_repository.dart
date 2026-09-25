import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/account.dart';

/// Frontière entre le domaine et la donnée pour la gestion des
/// comptes suivis par l'application. Purement local : contrairement
/// au référentiel de cartes, il n'y a ici aucune source distante.
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
}