/// Critères de tri proposés pour la liste des comptes.
///
/// Le compte principal reste toujours en tête, quel que soit le
/// critère : seul l'ordre des comptes secondaires change (voir
/// `AccountsState.sortedAccounts`).
enum AccountsSortOption {
  /// Ordre de création (comportement par défaut).
  creationOrder('Ordre de création'),

  /// Par nom, de A à Z (sans tenir compte de la casse).
  alphabetical('Alphabétique'),

  /// Par total de cartes possédées en plus du compte principal
  /// (losanges + étoiles), du plus grand au plus petit.
  extraCards('Cartes en plus');

  const AccountsSortOption(this.label);

  /// Libellé affiché dans le menu de tri.
  final String label;
}