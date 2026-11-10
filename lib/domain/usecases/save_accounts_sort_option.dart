import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/accounts_sort_option.dart';
import '../repositories/user_preferences_repository.dart';
import '../usecase.dart';

/// Mémorise le critère de tri de la liste des comptes, pour le
/// retrouver au prochain lancement.
class SaveAccountsSortOption implements UseCase<void, AccountsSortOption> {
  const SaveAccountsSortOption(this._repository);

  final UserPreferencesRepository _repository;

  @override
  Future<Either<Failure, void>> call(AccountsSortOption option) {
    return _repository.saveAccountsSortOption(option);
  }
}
