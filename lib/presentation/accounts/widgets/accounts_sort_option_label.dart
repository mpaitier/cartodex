import '../../../domain/entities/accounts_sort_option.dart';

/// Libellé affiché pour chaque critère de tri de la liste des comptes
/// (panneau de tri et de filtre). Gardé côté présentation : l'énumération
/// du domaine ne porte aucun texte d'interface.
extension AccountsSortOptionLabel on AccountsSortOption {
  String get label {
    switch (this) {
      case AccountsSortOption.creationOrder:
        return 'Ordre de création';
      case AccountsSortOption.alphabetical:
        return 'Alphabétique';
      case AccountsSortOption.extraCards:
        return 'Cartes en plus';
    }
  }
}
