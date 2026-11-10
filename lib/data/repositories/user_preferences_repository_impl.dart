import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/accounts_sort_option.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../datasources/local/user_preferences_local_data_source.dart';

/// Implémentation de [UserPreferencesRepository].
///
/// Chaque valeur d'énumération est stockée sous son nom
/// (ex: "alphabetical"). Une valeur qui ne correspond plus à aucun
/// critère (renommé ou retiré depuis) est ignorée et vaut `null` :
/// l'écran retombe alors sur son tri par défaut plutôt que d'échouer.
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  const UserPreferencesRepositoryImpl(this._localDataSource);

  final UserPreferencesLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AccountsSortOption?>> getAccountsSortOption() async {
    try {
      final stored = await _localDataSource.getAccountsSortOption();
      return Right(_parseSortOption(stored));
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

  static AccountsSortOption? _parseSortOption(String? stored) {
    if (stored == null) return null;
    for (final option in AccountsSortOption.values) {
      if (option.name == stored) return option;
    }
    return null;
  }
}
