import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_language.dart';
import '../repositories/user_preferences_repository.dart';
import '../usecase.dart';

/// Lit la langue d'affichage choisie lors d'un lancement précédent.
/// `null` tant que l'utilisateur n'en a choisi aucune.
class GetAppLanguage implements UseCase<AppLanguage?, NoParams> {
  const GetAppLanguage(this._repository);

  final UserPreferencesRepository _repository;

  @override
  Future<Either<Failure, AppLanguage?>> call(NoParams params) {
    return _repository.getAppLanguage();
  }
}
