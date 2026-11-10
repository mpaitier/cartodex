import '../../../domain/entities/accounts_sort_option.dart';
import '../../../l10n/l10n.dart';

/// Libellé affiché pour chaque critère de tri de la liste des comptes
/// (panneau de tri et de filtre). Gardé côté présentation : l'énumération
/// du domaine ne porte aucun texte d'interface.
extension AccountsSortOptionLabel on AccountsSortOption {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AccountsSortOption.creationOrder:
        return l10n.accountsSortCreationOrder;
      case AccountsSortOption.alphabetical:
        return l10n.accountsSortAlphabetical;
      case AccountsSortOption.extraCards:
        return l10n.accountsSortExtraCards;
    }
  }
}
