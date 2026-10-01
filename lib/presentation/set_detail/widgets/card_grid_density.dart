/// Densité de la grille de cartes du détail d'un set : le nombre de
/// colonnes et les proportions qui vont avec.
///
/// [comfortable] (3 colonnes) affiche nom, numéro et rareté sous
/// chaque illustration ; [compact] (5 colonnes, comme dans le jeu)
/// n'affiche que l'illustration et le badge de possession — le texte
/// ne tiendrait pas dans des tuiles aussi étroites.
enum CardGridDensity {
  comfortable(columns: 3, childAspectRatio: 0.68, spacing: 10),
  compact(columns: 5, childAspectRatio: 0.72, spacing: 6);

  const CardGridDensity({
    required this.columns,
    required this.childAspectRatio,
    required this.spacing,
  });

  final int columns;
  final double childAspectRatio;
  final double spacing;

  bool get isCompact => this == CardGridDensity.compact;

  /// L'autre densité, pour le bouton de bascule de l'AppBar.
  CardGridDensity get toggled =>
      isCompact ? CardGridDensity.comfortable : CardGridDensity.compact;
}