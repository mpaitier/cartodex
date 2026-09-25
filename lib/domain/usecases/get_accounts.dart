import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';
import '../usecase.dart';

/// Récupère tous les comptes suivis par l'application.
class GetAccounts implements UseCase<List<Account>, NoParams> {
  const GetAccounts(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) {
    return _repository.getAccounts();
  }
}