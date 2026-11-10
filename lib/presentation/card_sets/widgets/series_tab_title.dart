import '../../../l10n/l10n.dart';
import '../bloc/series_tab.dart';

/// Titre complet d'un onglet de série, pour le bandeau de progression
/// en haut de la série : "Série A" pour une série lettrée, le libellé
/// seul pour une section spéciale ("Deluxe", "Promo", qui se disent de
/// la même façon dans toutes les langues).
///
/// Gardé hors de [SeriesTab] : le modèle de l'onglet ne porte aucun
/// texte traduit.
extension SeriesTabTitle on SeriesTab {
  String title(AppLocalizations l10n) =>
      isSpecial ? label : l10n.seriesTitle(label);
}
