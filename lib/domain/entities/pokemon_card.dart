import 'package:equatable/equatable.dart';

import 'card_category.dart';

/// Représente une carte du référentiel.
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
    this.nameFr,
    this.imageUrl,
    this.rarity,
    this.hp,
    this.types = const [],
    this.illustrator,
    this.packs = const [],
  });

  /// Identifiant unique de la carte (ex: "A1-001").
  final String id;

  /// Numéro de la carte au sein de son set (ex: "1").
  final String localId;

  /// Nom anglais, tel que publié par le référentiel. Toujours renseigné,
  /// et seul utilisé pour retrouver l'illustration de la carte (les
  /// noms de fichier de pocketcards.net partent du nom anglais).
  final String name;

  /// Nom français, ou `null` quand le référentiel n'en fournit pas (ou
  /// qu'il est identique au nom anglais). Pour l'affichage, passer par
  /// [localizedName], qui retombe sur [name].
  final String? nameFr;

  final CardCategory category;

  /// Identifiant du set auquel appartient la carte.
  final String setId;

  /// Nom du set, dénormalisé ici pour éviter une jointure
  /// systématique à l'affichage (liste de cartes, recherche...).
  final String setName;

  final String? imageUrl;

  /// Code de rareté brut renvoyé par la source (ex: "C", "RR",
  /// "SAR"). Conservé en chaîne libre plutôt qu'en enum fermé : le
  /// référentiel distant fait foi sur la nomenclature.
  final String? rarity;

  /// Points de vie. Non pertinent (null) pour les cartes qui ne
  /// sont pas de catégorie [CardCategory.pokemon].
  final int? hp;

  final List<String> types;

  final String? illustrator;

  /// Boosters dans lesquels cette carte peut être tirée (ex:
  /// ["Mewtwo"], ou plusieurs pour les cartes communes à tout le
  /// set). Vide pour certaines cartes hors-booster (crossover
  /// rares).
  final List<String> packs;

  /// Nom à afficher pour la langue [languageCode] (code ISO 639-1, ex:
  /// "fr") : le nom français quand il existe et que l'app est en
  /// français, le nom anglais dans tous les autres cas.
  String localizedName(String languageCode) {
    final french = nameFr;
    if (languageCode == 'fr' && french != null && french.isNotEmpty) {
      return french;
    }
    return name;
  }

  @override
  List<Object?> get props => [
        id,
        localId,
        name,
        nameFr,
        category,
        setId,
        setName,
        imageUrl,
        rarity,
        hp,
        types,
        illustrator,
        packs,
      ];
}