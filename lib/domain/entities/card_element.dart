import 'pokemon_card.dart';

/// Élément d'une carte (Plante, Feu, Eau...), pour le filtre par type
/// du détail d'un set.
///
/// Les valeurs suivent l'ordre du jeu. [none] regroupe les cartes
/// sans élément : les Dresseurs (Supporters, Objets, Outils, Stades)
/// et les Fossiles.
///
/// L'élément vient de `cards.extra.json` (champ `element`) et se lit
/// dans `PokemonCard.types` (voir [CardElement.of]). Les cartes
/// synchronisées avant l'ajout de ce champ n'ont pas encore d'élément :
/// elles tombent dans [none] jusqu'à la prochaine synchronisation du
/// référentiel.
enum CardElement {
  grass('grass'),
  fire('fire'),
  water('water'),
  lightning('lightning'),
  psychic('psychic'),
  fighting('fighting'),
  darkness('darkness'),
  metal('metal'),
  dragon('dragon'),
  colorless('colorless'),

  /// Pas d'élément (Dresseurs, Fossiles).
  none(null);

  const CardElement(this.code);

  /// Code brut du référentiel distant (ex: "grass"). `null` pour
  /// [none].
  final String? code;

  /// Élément de [card], d'après le premier code reconnu de ses
  /// `types`. [none] si elle n'en a aucun, ou aucun connu.
  static CardElement of(PokemonCard card) {
    for (final type in card.types) {
      for (final element in values) {
        if (element.code == type) return element;
      }
    }
    return none;
  }
}
