/// Critères de tri proposés pour la liste des comptes.
///
/// Le compte principal reste toujours en tête, quel que soit le
/// critère : seul l'ordre des comptes secondaires change (voir
/// `AccountsState.sortedAccounts`).
///
/// Entité du domaine, et non simple détail d'affichage : le choix est
/// mémorisé d'un lancement à l'autre (voir `UserPreferencesRepository`).
/// Les libellés affichés restent dans la présentation
/// (`AccountsSortOptionLabel`).
enum AccountsSortOption {
  /// Ordre de création (comportement par défaut).
  creationOrder,

  /// Par nom, de A à Z (sans tenir compte de la casse).
  alphabetical,

  /// Par total de cartes possédées en plus du compte principal
  /// (losanges + étoiles), du plus grand au plus petit.
  extraCards,
}
