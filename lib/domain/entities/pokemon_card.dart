import 'package:equatable/equatable.dart';

import 'card_category.dart';

/// Représente une carte du référentiel TCGdex.
///
/// Nommée `PokemonCard` plutôt que `Card` pour éviter toute
/// collision avec le widget `Card` de Material
/// (`package:flutter/material.dart`), qui sera importé dans la
/// quasi-totalité des écrans côté présentation.
class PokemonCard extends Equatable {
  const PokemonCard({
    required this.id,
    required this.localId,
    required this.name,
    required this.category,
    required this.setId,
    required this.setName,
    this.imageUrl,
    this.rarity,
    this.hp,
    this.types = const [],
    this.illustrator,
  });

  /// Identifiant unique TCGdex de la carte (ex: "A1-001").
  final String id;

  /// Numéro de la carte au sein de son set (ex: "001").
  final String localId;

  final String name;

  final CardCategory category;

  /// Identifiant du set auquel appartient la carte.
  final String setId;

  /// Nom du set, dénormalisé ici pour éviter une jointure
  /// systématique à l'affichage (liste de cartes, recherche...).
  final String setName;

  final String? imageUrl;

  /// Rareté brute renvoyée par TCGdex (ex: "◊◊", "☆☆☆", "Rare").
  ///
  /// Conservée en chaîne libre plutôt qu'en enum fermé : la
  /// nomenclature exacte utilisée par TCG Pocket sera confirmée à
  /// l'implémentation du datasource distant, sur un vrai payload
  /// d'API, plutôt que d'être devinée ici.
  final String? rarity;

  /// Points de vie. Non pertinent (null) pour les cartes qui ne
  /// sont pas de catégorie [CardCategory.pokemon].
  final int? hp;

  final List<String> types;

  final String? illustrator;

  @override
  List<Object?> get props => [
        id,
        localId,
        name,
        category,
        setId,
        setName,
        imageUrl,
        rarity,
        hp,
        types,
        illustrator,
      ];
}