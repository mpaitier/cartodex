import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/account_repository.dart';
import '../usecase.dart';

/// Modifie le nom et le code ami d'un compte existant.
class UpdateAccount implements UseCase<void, UpdateAccountParams> {
  const UpdateAccount(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, void>> call(UpdateAccountParams params) {
    return _repository.updateAccount(
      accountId: params.accountId,
      name: params.name,
      gameAccountId: params.gameAccountId,
    );
  }
}

/// Paramètres attendus par [UpdateAccount].
class UpdateAccountParams extends Equatable {
  const UpdateAccountParams({
    required this.accountId,
    required this.name,
    required this.gameAccountId,
  });

  final String accountId;
  final String name;
  final String gameAccountId;

  @override
  List<Object?> get props => [accountId, name, gameAccountId];
}
