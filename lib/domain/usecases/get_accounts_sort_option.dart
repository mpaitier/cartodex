import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/accounts_sort_option.dart';
import '../repositories/user_preferences_repository.dart';
import '../usecase.dart';

/// Lit le critère de tri de la liste des comptes choisi lors d'un
/// lancement précédent. `null` tant que l'utilisateur n'en a choisi
/// aucun.
class GetAccountsSortOption
    implements UseCase<AccountsSortOption?, NoParams> {
  const GetAccountsSortOption(this._repository);

  final UserPreferencesRepository _repository;

  @override
  Future<Either<Failure, AccountsSortOption?>> call(NoParams params) {
    return _repository.getAccountsSortOption();
  }
}
