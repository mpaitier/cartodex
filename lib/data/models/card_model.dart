import '../../domain/entities/card_category.dart';
import '../../domain/entities/pokemon_card.dart';

/// DTO de la carte, tel que reçu depuis TCGdex (`GET /cards/{id}`)
/// ou relu depuis le cache local.
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
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final set = json['set'] as Map<String, dynamic>?;
    return CardModel(
      id: json['id'] as String,
      localId: json['localId'] as String,
      name: json['name'] as String,
      category: _categoryFromApi(json['category'] as String?),
      setId: set?['id'] as String? ?? '',
      setName: set?['name'] as String? ?? '',
      imageUrl: json['image'] as String?,
      rarity: json['rarity'] as String?,
      hp: (json['hp'] as num?)?.toInt(),
      types: (json['types'] as List<dynamic>?)?.cast<String>() ?? const [],
      illustrator: json['illustrator'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localId': localId,
      'name': name,
      'category': category.name,
      'set': {'id': setId, 'name': setName},
      'image': imageUrl,
      'rarity': rarity,
      'hp': hp,
      'types': types,
      'illustrator': illustrator,
    };
  }

  /// Convertit la chaîne brute renvoyée par TCGdex (`"Pokemon"`,
  /// `"Trainer"`, `"Energy"`) en [CardCategory]. Toute valeur
  /// inconnue retombe sur [CardCategory.trainer] plutôt que de
  /// planter la synchronisation entière pour une seule carte.
  static CardCategory _categoryFromApi(String? raw) {
    switch (raw) {
      case 'Pokemon':
      case 'Pokémon':
        return CardCategory.pokemon;
      case 'Energy':
        return CardCategory.energy;
      case 'Trainer':
      default:
        return CardCategory.trainer;
    }
  }
}