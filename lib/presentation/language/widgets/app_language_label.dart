import '../../../domain/entities/app_language.dart';
import '../../../l10n/l10n.dart';

/// Libellé affiché pour chaque langue du menu de langue. Gardé côté
/// présentation : l'énumération du domaine ne porte aucun texte
/// d'interface.
///
/// Le français et l'anglais s'écrivent toujours dans leur propre langue
/// ("Français", "English"), pour qu'on retrouve la sienne même dans une
/// interface qu'on ne lit pas.
extension AppLanguageLabel on AppLanguage {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AppLanguage.system:
        return l10n.languageSystem;
      case AppLanguage.french:
        return l10n.languageFrench;
      case AppLanguage.english:
        return l10n.languageEnglish;
    }
  }
}
