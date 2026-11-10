import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/accounts_sort_option.dart';
import '../entities/app_language.dart';

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

  /// Langue d'affichage enregistrée, ou `null` si aucun choix n'a
  /// encore été fait (ou si la valeur stockée n'est plus reconnue).
  Future<Either<Failure, AppLanguage?>> getAppLanguage();

  /// Enregistre [language] comme langue d'affichage.
  Future<Either<Failure, void>> saveAppLanguage(AppLanguage language);

  /// Dates des synchronisations cloud réussies du compte applicatif
  /// [userId] sur cet appareil (voir `SyncRateLimit`). Liste vide si
  /// aucune n'a été enregistrée ; une date illisible est ignorée.
  Future<Either<Failure, List<DateTime>>> getSyncHistory(String userId);

  /// Remplace l'historique des synchronisations de [userId] par
  /// [history].
  Future<Either<Failure, void>> saveSyncHistory(
    String userId,
    List<DateTime> history,
  );
}
