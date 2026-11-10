import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/accounts_sort_option.dart';
import '../../domain/entities/app_language.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../datasources/local/user_preferences_local_data_source.dart';

/// Implémentation de [UserPreferencesRepository].
///
/// Chaque valeur d'énumération est stockée sous son nom
/// (ex: "alphabetical", "english"). Une valeur qui ne correspond plus
/// à aucune entrée (renommée ou retirée depuis) est ignorée et vaut
/// `null` : l'écran retombe alors sur son réglage par défaut plutôt
/// que d'échouer.
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  const UserPreferencesRepositoryImpl(this._localDataSource);

  final UserPreferencesLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AccountsSortOption?>> getAccountsSortOption() async {
    try {
      final stored = await _localDataSource.getAccountsSortOption();
      return Right(_parseEnum(AccountsSortOption.values, stored));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveAccountsSortOption(
    AccountsSortOption option,
  ) async {
    try {
      await _localDataSource.saveAccountsSortOption(option.name);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AppLanguage?>> getAppLanguage() async {
    try {
      final stored = await _localDataSource.getAppLanguage();
      return Right(_parseEnum(AppLanguage.values, stored));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveAppLanguage(AppLanguage language) async {
    try {
      await _localDataSource.saveAppLanguage(language.name);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  /// Valeur de [values] dont le nom vaut [stored], ou `null` si
  /// [stored] est absent ou ne correspond plus à rien.
  static T? _parseEnum<T extends Enum>(List<T> values, String? stored) {
    if (stored == null) return null;
    for (final value in values) {
      if (value.name == stored) return value;
    }
    return null;
  }
}
