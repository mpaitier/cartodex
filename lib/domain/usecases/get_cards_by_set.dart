import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../entities/pokemon_card.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Récupère toutes les cartes appartenant à un set donné.
class GetCardsBySet implements UseCase<List<PokemonCard>, GetCardsBySetParams> {
  const GetCardsBySet(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, List<PokemonCard>>> call(GetCardsBySetParams params) {
    return _repository.getCardsBySet(params.setId);
  }
}

/// Paramètre attendu par [GetCardsBySet].
class GetCardsBySetParams extends Equatable {
  const GetCardsBySetParams({required this.setId});

  final String setId;

  @override
  List<Object?> get props => [setId];
}