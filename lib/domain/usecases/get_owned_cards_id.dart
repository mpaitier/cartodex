import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Récupère l'ensemble des identifiants de cartes marquées comme
/// possédées par un compte donné, uniquement issu de la base
/// locale.
class GetOwnedCardIds implements UseCase<Set<String>, GetOwnedCardIdsParams> {
  const GetOwnedCardIds(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, Set<String>>> call(GetOwnedCardIdsParams params) {
    return _repository.getOwnedCardIds(params.accountId);
  }
}

/// Paramètres attendus par [GetOwnedCardIds].
class GetOwnedCardIdsParams extends Equatable {
  const GetOwnedCardIdsParams({required this.accountId});

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}