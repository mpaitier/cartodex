import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_language.dart';
import '../repositories/user_preferences_repository.dart';
import '../usecase.dart';

/// Mémorise la langue d'affichage, pour la retrouver au prochain
/// lancement.
class SaveAppLanguage implements UseCase<void, AppLanguage> {
  const SaveAppLanguage(this._repository);

  final UserPreferencesRepository _repository;

  @override
  Future<Either<Failure, void>> call(AppLanguage language) {
    return _repository.saveAppLanguage(language);
  }
}
