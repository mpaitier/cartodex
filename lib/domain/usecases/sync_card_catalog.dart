import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../repositories/card_repository.dart';
import '../usecase.dart';

/// Déclenche la synchronisation du référentiel de cartes auprès de
/// l'API TCGdex. N'a aucun effet sur les cartes possédées, qui
/// restent uniquement gérées en local.
class SyncCardCatalog implements UseCase<void, NoParams> {
  const SyncCardCatalog(this._repository);

  final CardRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.syncCardCatalog();
  }
}