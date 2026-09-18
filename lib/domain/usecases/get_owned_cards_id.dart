import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Récupère l'ensemble des identifiants de cartes marquées comme
/// possédées par l'utilisateur, uniquement issu de la base locale.
class GetOwnedCardIds implements UseCase<Set<String>, NoParams> {
  const GetOwnedCardIds(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, Set<String>>> call(NoParams params) {
    return _repository.getOwnedCardIds();
  }
}