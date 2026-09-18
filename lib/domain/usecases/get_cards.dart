import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../entities/card_set.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Récupère la liste des sets de cartes présents dans le
/// référentiel local (déjà synchronisés depuis TCGdex).
class GetCardSets implements UseCase<List<CardSet>, NoParams> {
  const GetCardSets(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, List<CardSet>>> call(NoParams params) {
    return _repository.getCardSets();
  }
}