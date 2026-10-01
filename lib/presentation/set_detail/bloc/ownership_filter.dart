/// Filtre de possession du détail d'un set.
///
/// Les trois valeurs autres que [all] correspondent exactement aux
/// trois états du badge de `CardGridItem`, et forment une partition :
/// une carte est dans une seule d'entre elles.
enum OwnershipFilter {
  /// Aucun filtre de possession (défaut).
  all,

  /// Cartes possédées par le compte principal (badge violet).
  primary,

  /// Cartes possédées par au moins un compte secondaire, mais pas
  /// par le principal (badge jaune).
  secondary,

  /// Cartes possédées par aucun compte (badge neutre).
  notOwned,
}