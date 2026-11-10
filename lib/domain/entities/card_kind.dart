import 'card_category.dart';
import 'pokemon_card.dart';

/// Type d'une carte pour le filtre par type du détail d'un set :
/// l'élément pour un Pokémon (Plante, Feu, Eau...), le type de
/// Dresseur sinon (Supporter, Objet, Outil, Stade, Fossile).
///
/// Les éléments suivent l'ordre du jeu, puis viennent les Dresseurs.
/// [unknown] regroupe les cartes dont le référentiel ne dit rien
/// (absentes de `cards.extra.json`, ou synchronisées avant que ces
/// détails ne soient lus) : une synchronisation du référentiel les
/// range dans le bon type.
enum CardKind {
  grass,
  fire,
  water,
  lightning,
  psychic,
  fighting,
  darkness,
  metal,
  dragon,
  colorless,
  supporter,
  item,
  tool,
  stadium,
  fossil,
  unknown;

  /// Vrai pour les éléments de Pokémon, faux pour les Dresseurs et
  /// [unknown].
  bool get isElement => index <= colorless.index;

  /// Type de [card] : son élément si c'est un Pokémon (lu dans
  /// `PokemonCard.types`, ex: "grass"), son type de Dresseur sinon
  /// (`PokemonCard.category`). [unknown] quand ni l'un ni l'autre
  /// n'est connu, y compris pour un Pokémon sans élément reconnu.
  static CardKind of(PokemonCard card) {
    switch (card.category) {
      case CardCategory.pokemon:
        return _elementOf(card) ?? unknown;
      case CardCategory.supporter:
        return supporter;
      case CardCategory.item:
        return item;
      case CardCategory.tool:
        return tool;
      case CardCategory.stadium:
        return stadium;
      case CardCategory.fossil:
        return fossil;
      case CardCategory.unknown:
        return unknown;
    }
  }

  /// Premier élément reconnu parmi les `types` de [card] : chaque code
  /// du référentiel ("grass", "fire"...) porte le nom d'une valeur
  /// d'élément de cette énumération.
  static CardKind? _elementOf(PokemonCard card) {
    for (final type in card.types) {
      for (final kind in values) {
        if (kind.isElement && kind.name == type) return kind;
      }
    }
    return null;
  }
}
