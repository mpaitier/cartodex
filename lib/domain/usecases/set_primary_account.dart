import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/account_repository.dart';
import '../usecase.dart';

/// Fait d'un compte le nouveau compte principal.
class SetPrimaryAccount implements UseCase<void, SetPrimaryAccountParams> {
  const SetPrimaryAccount(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, void>> call(SetPrimaryAccountParams params) {
    return _repository.setPrimaryAccount(params.accountId);
  }
}

/// Paramètre attendu par [SetPrimaryAccount].
class SetPrimaryAccountParams extends Equatable {
  const SetPrimaryAccountParams({required this.accountId});

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}