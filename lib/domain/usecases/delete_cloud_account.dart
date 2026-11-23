import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/account_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/cloud_sync_repository.dart';
import '../repositories/user_preferences_repository.dart';
import '../usecase.dart';

/// Supprime le compte applicatif connecté et ses données.
///
/// Dans l'ordre :
/// 1. confirmation de l'identité (mot de passe ou Google), exigée par
///    Firebase pour supprimer un compte ;
/// 2. suppression des comptes de jeu et de la possession dans le
///    cloud, tant que l'utilisateur existe encore (les règles Firestore
///    n'autorisent que le propriétaire) ;
/// 3. suppression du compte applicatif ;
/// 4. oubli de l'historique de synchronisation gardé sur le téléphone ;
/// 5. sur demande, effacement de la collection du téléphone.
///
/// Chaque étape s'arrête au premier échec, et une étape irréversible
/// n'est jamais lancée si la précédente a échoué. L'historique de
/// synchronisation est le seul échec ignoré : il ne sert plus à rien
/// une fois le compte supprimé.
class DeleteCloudAccount implements UseCase<void, DeleteCloudAccountParams> {
  const DeleteCloudAccount({
    required AuthRepository authRepository,
    required CloudSyncRepository cloudSyncRepository,
    required UserPreferencesRepository userPreferencesRepository,
    required AccountRepository accountRepository,
  })  : _authRepository = authRepository,
        _cloudSyncRepository = cloudSyncRepository,
        _userPreferencesRepository = userPreferencesRepository,
        _accountRepository = accountRepository;

  final AuthRepository _authRepository;
  final CloudSyncRepository _cloudSyncRepository;
  final UserPreferencesRepository _userPreferencesRepository;
  final AccountRepository _accountRepository;

  @override
  Future<Either<Failure, void>> call(DeleteCloudAccountParams params) async {
    final reauthenticated =
        await _authRepository.reauthenticate(password: params.password);
    if (reauthenticated.isLeft()) return reauthenticated;

    final cloudDeleted =
        await _cloudSyncRepository.deleteAllAccounts(params.userId);
    if (cloudDeleted.isLeft()) return cloudDeleted;

    final userDeleted = await _authRepository.deleteCurrentUser();
    if (userDeleted.isLeft()) return userDeleted;

    await _userPreferencesRepository.saveSyncHistory(params.userId, const []);

    if (params.deleteLocalData) {
      final localDeleted = await _accountRepository.deleteAllLocalData();
      if (localDeleted.isLeft()) {
        return const Left(
          CacheFailure(
            'Compte cloud supprimé, mais la collection du téléphone '
            "n'a pas pu être effacée.",
          ),
        );
      }
    }
    return const Right(null);
  }
}

/// Paramètres attendus par [DeleteCloudAccount].
class DeleteCloudAccountParams extends Equatable {
  const DeleteCloudAccountParams({
    required this.userId,
    this.password,
    this.deleteLocalData = false,
  });

  final String userId;

  /// Mot de passe de confirmation ; `null` pour confirmer avec Google
  /// (compte sans mot de passe).
  final String? password;

  /// Efface aussi les comptes de jeu et la possession du téléphone.
  final bool deleteLocalData;

  @override
  List<Object?> get props => [userId, password, deleteLocalData];
}
