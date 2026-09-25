import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Marque une carte comme possédée ou non par un compte donné.
/// N'appelle jamais l'API : cette information ne vit qu'en local.
class SetCardOwned implements UseCase<void, SetCardOwnedParams> {
  const SetCardOwned(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, void>> call(SetCardOwnedParams params) {
    return _repository.setCardOwned(
      cardId: params.cardId,
      accountId: params.accountId,
      owned: params.owned,
    );
  }
}

/// Paramètres attendus par [SetCardOwned].
class SetCardOwnedParams extends Equatable {
  const SetCardOwnedParams({
    required this.cardId,
    required this.accountId,
    required this.owned,
  });

  final String cardId;
  final String accountId;
  final bool owned;

  @override
  List<Object?> get props => [cardId, accountId, owned];
}