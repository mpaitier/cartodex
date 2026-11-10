/// Langue d'affichage choisie dans l'application.
///
/// Entité du domaine, comme `AccountsSortOption` : le choix est
/// mémorisé d'un lancement à l'autre (voir `UserPreferencesRepository`).
/// Les libellés affichés restent dans la présentation
/// (`AppLanguageLabel`).
enum AppLanguage {
  /// Suit la langue du téléphone (comportement par défaut). Une langue
  /// autre que le français ou l'anglais retombe sur l'anglais.
  system,

  french,

  english;

  /// Code de langue ISO 639-1 imposé à l'application, ou `null` pour
  /// laisser le téléphone décider ([system]).
  String? get languageCode {
    switch (this) {
      case AppLanguage.system:
        return null;
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.english:
        return 'en';
    }
  }
}
