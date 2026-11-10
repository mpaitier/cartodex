import '../../core/constants/app_constants.dart';
import '../../core/utils/pocket_cards_image_slug.dart';
import '../../domain/entities/card_category.dart';
import '../../domain/entities/pokemon_card.dart';

/// DTO de la carte, tel que reçu depuis `cards.json` /
/// `cards.extra.json`
/// (https://github.com/flibustier/pokemon-tcg-pocket-database) ou
/// relu depuis le cache local.
class CardModel extends PokemonCard {
  const CardModel({
    required super.id,
    required super.localId,
    required super.name,
    required super.category,
    required super.setId,
    required super.setName,
    super.imageUrl,
    super.rarity,
    super.hp,
    super.types,
    super.illustrator,
    super.packs,
  });

  /// `cards.json` ne contient pas le nom du set, ni le type de la
  /// carte (Pokémon, Supporter, Objet...), ni son élément (Plante,
  /// Feu...), ni ses PV : le nom est retrouvé après coup via
  /// [copyWith] (le repository connaît déjà les sets), et [category],
  /// [element] et [hp] sont passés séparément ici, croisés avec
  /// `cards.extra.json` par le datasource distant. L'élément brut (ex:
  /// "grass") devient l'unique valeur de `types` ; une carte sans
  /// élément (Dresseurs) garde une liste vide.
  ///
  /// Exemple d'entrée `cards.json` :
  /// ```json
  /// {
  ///   "set": "A1",
  ///   "number": 1,
  ///   "rarity": "C",
  ///   "name": "Bulbasaur",
  ///   "image": "cPK_10_000010_00_FUSHIGIDANE_C.webp",
  ///   "packs": ["Mewtwo"]
  /// }
  /// ```
  factory CardModel.fromJson(
    Map<String, dynamic> json, {
    String? category,
    String? element,
    int? hp,
  }) {
    final setId = json['set'] as String;
    final number = json['number'].toString();
    final name = json['name'] as String;
    final id = '$setId-$number';
    return CardModel(
      id: id,
      localId: number,
      name: name,
      category: _categoryFromApi(category),
      setId: setId,
      // Renseigné par le repository (voir CardRepositoryImpl.syncCardCatalog),
      // qui dispose déjà des noms de sets au moment du groupement par set.
      setName: '',
      // `pokemon-tcg-pocket-database` ne fournit qu'un nom de
      // fichier, pas une URL exploitable, et TCGdex n'héberge pas
      // les images TCG Pocket (voir AppConstants.pocketCardsImageBaseUrl
      // pour l'historique complet). L'URL est reconstruite ici à
      // partir du nom de la carte (voir [PocketCardsImageSlug]) et
      // du numéro sur 3 chiffres, seul format observé sur
      // pocketcards.net. [PocketCardsImageSlug.fromCardName] vérifie
      // d'abord une table de correctifs manuels avant la conversion
      // générique, pour les quelques cartes dont le nom brut du
      // référentiel distant contient une erreur de saisie (voir sa
      // documentation). Le code de set passe lui aussi par
      // [PocketCardsImageSlug.fromSetCode], le site abrégeant les
      // promos ("PROMO-B" → "pb").
      imageUrl: '${AppConstants.pocketCardsImageBaseUrl}/'
          '${PocketCardsImageSlug.fromCardName(id, name)}-'
          '${PocketCardsImageSlug.fromSetCode(setId)}-'
          '${number.padLeft(3, '0')}.webp',
      rarity: json['rarity'] as String?,
      hp: hp,
      types: element == null || element.isEmpty ? const [] : [element],
      packs: (json['packs'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  CardModel copyWith({String? setName}) {
    return CardModel(
      id: id,
      localId: localId,
      name: name,
      category: category,
      setId: setId,
      setName: setName ?? this.setName,
      imageUrl: imageUrl,
      rarity: rarity,
      hp: hp,
      types: types,
      illustrator: illustrator,
      packs: packs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set': setId,
      'number': localId,
      'name': name,
      'rarity': rarity,
      'packs': packs,
    };
  }

  /// Convertit le `type` brut de `cards.extra.json` (`"pokemon"`,
  /// `"supporter"`, `"item"`, `"tool"`, `"stadium"`, `"Fossil"`) en
  /// [CardCategory], sans tenir compte de la casse (le référentiel
  /// écrit "Fossil" avec une majuscule). Absent ou inconnu retombe sur
  /// [CardCategory.unknown] plutôt que de planter la synchronisation
  /// entière pour une seule carte.
  static CardCategory _categoryFromApi(String? raw) {
    return CardCategory.fromName(raw?.toLowerCase());
  }
}