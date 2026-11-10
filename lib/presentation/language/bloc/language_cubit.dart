import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/app_language.dart';
import '../../../domain/usecase.dart';
import '../../../domain/usecases/get_app_language.dart';
import '../../../domain/usecases/save_app_language.dart';

/// ViewModel de la langue d'affichage, commun à toute l'application.
///
/// Fourni une seule fois à la racine (voir `CartodexApp`), comme
/// `RarityScopeCubit` : `MaterialApp` lit son état pour choisir sa
/// `locale`, et tous les écrans changent de langue d'un coup.
///
/// Contrairement au périmètre de raretés, le choix est persisté :
/// [load] le relit au démarrage (appelé dans `main.dart`, avant le
/// premier affichage, pour que l'app ne s'ouvre pas une fraction de
/// seconde dans la mauvaise langue) et [select] l'enregistre.
class LanguageCubit extends Cubit<AppLanguage> {
  LanguageCubit({
    required GetAppLanguage getAppLanguage,
    required SaveAppLanguage saveAppLanguage,
  })  : _getAppLanguage = getAppLanguage,
        _saveAppLanguage = saveAppLanguage,
        super(AppLanguage.system);

  final GetAppLanguage _getAppLanguage;
  final SaveAppLanguage _saveAppLanguage;

  /// Relit la langue enregistrée. Une lecture impossible n'empêche pas
  /// l'app de démarrer : elle reste sur la langue du téléphone.
  Future<void> load() async {
    final result = await _getAppLanguage(const NoParams());
    result.fold(
      (failure) => AppLogger.log(
        'WARNING',
        'Langue enregistrée illisible : ${failure.message}',
      ),
      (language) {
        if (language != null) emit(language);
      },
    );
  }

  /// Change la langue tout de suite, puis l'enregistre. Un échec
  /// d'enregistrement ne revient pas en arrière : la langue choisie
  /// reste active jusqu'au prochain lancement.
  Future<void> select(AppLanguage language) async {
    if (language == state) return;
    emit(language);
    final result = await _saveAppLanguage(language);
    result.fold(
      (failure) => AppLogger.log(
        'WARNING',
        'Langue non mémorisée : ${failure.message}',
      ),
      (_) {},
    );
  }
}
