import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/account_repository.dart';
import '../usecase.dart';

/// Crée un compte suivi par l'application.
class AddAccount implements UseCase<void, AddAccountParams> {
  const AddAccount(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, void>> call(AddAccountParams params) {
    return _repository.addAccount(
      name: params.name,
      gameAccountId: params.gameAccountId,
    );
  }
}

/// Paramètres attendus par [AddAccount].
class AddAccountParams extends Equatable {
  const AddAccountParams({required this.name, required this.gameAccountId});

  final String name;
  final String gameAccountId;

  @override
  List<Object?> get props => [name, gameAccountId];
}