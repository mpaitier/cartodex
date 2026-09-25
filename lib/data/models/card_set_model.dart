import '../../domain/entities/card_set.dart';

/// DTO du set de carte, tel que reçu depuis `sets.json`
/// (https://github.com/flibustier/pokemon-tcg-pocket-database) ou
/// relu depuis le cache local.
class CardSetModel extends CardSet {
  const CardSetModel({
    required super.id,
    required super.name,
    required super.totalCardCount,
    required super.seriesId,
    super.logoUrl,
    super.officialCardCount,
    super.packs,
  });

  /// `sets.json` regroupe les sets par série (clé "A", "B", ...) ;
  /// chaque élément individuel a cette forme :
  /// ```json
  /// {
  ///   "code": "A1",
  ///   "releaseDate": "2024-10-30",
  ///   "count": 286,
  ///   "name": { "en": "Genetic Apex", "fr": "Puissance Génétique", ... },
  ///   "packs": ["Charizard", "Mewtwo", "Pikachu"]
  /// }
  /// ```
  /// [seriesId] n'est pas dans l'objet lui-même : c'est la clé du
  /// groupe qui le contient dans `sets.json` (ex: "A"), fournie par
  /// l'appelant plutôt que par le JSON individuel du set — voir
  /// `CardRemoteDataSourceImpl.fetchCardSets`. `count` est absent
  /// pour certains sets (ex: "Promo B") : `totalCardCount` retombe
  /// alors à 0 ici, corrigé ensuite avec le vrai nombre de cartes
  /// synchronisées (voir `CardRepositoryImpl.syncCardCatalog`).
  factory CardSetModel.fromJson(
    Map<String, dynamic> json, {
    required String seriesId,
  }) {
    final names = json['name'] as Map<String, dynamic>?;
    return CardSetModel(
      id: json['code'] as String,
      name: (names?['en'] as String?) ?? json['code'] as String,
      totalCardCount: (json['count'] as num?)?.toInt() ?? 0,
      seriesId: seriesId,
      packs: (json['packs'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': id,
      'name': {'en': name},
      'count': totalCardCount,
      'packs': packs,
    };
  }
}