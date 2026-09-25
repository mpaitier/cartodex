import '../../core/constants/app_constants.dart';
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

  /// `cards.json` ne contient pas le nom du set ni la catégorie de
  /// la carte (Pokémon / Dresseur / Énergie) : le nom est retrouvé
  /// après coup via [copyWith] (le repository connaît déjà les
  /// sets), et [category] est passée séparément ici, croisée avec
  /// `cards.extra.json` par le datasource distant.
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
  factory CardModel.fromJson(Map<String, dynamic> json, {String? category}) {
    final setId = json['set'] as String;
    final number = json['number'].toString();
    return CardModel(
      id: '$setId-$number',
      localId: number,
      name: json['name'] as String,
      category: _categoryFromApi(category),
      setId: setId,
      // Renseigné par le repository (voir CardRepositoryImpl.syncCardCatalog),
      // qui dispose déjà des noms de sets au moment du groupement par set.
      setName: '',
      // Le jeu de données ne fournit qu'un nom de fichier, pas une
      // URL : on reconstruit celle-ci via la convention
      // "cards-by-set" documentée depuis la v2.1.0 du package
      // (cards-by-set/{set}/{number}.webp). Non vérifiée avec
      // certitude côté hébergement (voir README) : si l'image ne
      // charge pas, CardGridItem retombe sur le numéro affiché en
      // grand, donc une URL incorrecte ne casse rien.
      imageUrl:
          '${AppConstants.pocketDatabaseBaseUrl}/cards-by-set/$setId/$number.webp',
      rarity: json['rarity'] as String?,
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
  /// `"trainer"`, `"energy"`) en [CardCategory]. Absent ou inconnu
  /// retombe sur [CardCategory.trainer] plutôt que de planter la
  /// synchronisation entière pour une seule carte.
  static CardCategory _categoryFromApi(String? raw) {
    switch (raw) {
      case 'pokemon':
        return CardCategory.pokemon;
      case 'energy':
        return CardCategory.energy;
      case 'trainer':
      default:
        return CardCategory.trainer;
    }
  }
}