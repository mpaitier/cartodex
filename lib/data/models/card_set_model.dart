import '../../domain/entities/card_set.dart';

/// DTO du set de carte, tel que reçu depuis TCGdex
/// (`GET /series/tcgp`, chaque élément du tableau `sets`) ou relu
/// depuis le cache local.
class CardSetModel extends CardSet {
  const CardSetModel({
    required super.id,
    required super.name,
    required super.totalCardCount,
    super.logoUrl,
    super.officialCardCount,
  });

  factory CardSetModel.fromJson(Map<String, dynamic> json) {
    final cardCount = json['cardCount'] as Map<String, dynamic>?;
    return CardSetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo'] as String?,
      totalCardCount: (cardCount?['total'] as num?)?.toInt() ?? 0,
      officialCardCount: (cardCount?['official'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logoUrl,
      'cardCount': {
        'total': totalCardCount,
        'official': officialCardCount,
      },
    };
  }
}