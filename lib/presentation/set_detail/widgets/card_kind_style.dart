import 'package:flutter/material.dart';

import '../../../domain/entities/card_kind.dart';

/// Libellé et repère visuel de chaque type de carte dans le filtre par
/// type. Gardés côté présentation : l'énumération du domaine ne porte
/// ni texte ni couleur d'interface.
///
/// Les éléments de Pokémon s'affichent avec leur logo officiel
/// (`CardElementLogo`) ; leur couleur ([color]), reprise de la teinte
/// habituelle de chaque type, sert de pastille de repli tant que le
/// logo n'est pas chargé. Les types de Dresseur et [CardKind.unknown]
/// ont une icône ([icon]).
extension CardKindStyle on CardKind {
  String get label {
    switch (this) {
      case CardKind.grass:
        return 'Plante';
      case CardKind.fire:
        return 'Feu';
      case CardKind.water:
        return 'Eau';
      case CardKind.lightning:
        return 'Électrique';
      case CardKind.psychic:
        return 'Psy';
      case CardKind.fighting:
        return 'Combat';
      case CardKind.darkness:
        return 'Obscurité';
      case CardKind.metal:
        return 'Métal';
      case CardKind.dragon:
        return 'Dragon';
      case CardKind.colorless:
        return 'Incolore';
      case CardKind.supporter:
        return 'Supporter';
      case CardKind.item:
        return 'Objet';
      case CardKind.tool:
        return 'Outil';
      case CardKind.stadium:
        return 'Stade';
      case CardKind.fossil:
        return 'Fossile';
      case CardKind.unknown:
        return 'Inconnu';
    }
  }

  /// Couleur de repli d'un élément (voir `CardElementLogo`) ; `null`
  /// pour les Dresseurs et [CardKind.unknown], qui utilisent [icon].
  Color? get color {
    switch (this) {
      case CardKind.grass:
        return const Color(0xFF7AC74C);
      case CardKind.fire:
        return const Color(0xFFEE8130);
      case CardKind.water:
        return const Color(0xFF6390F0);
      case CardKind.lightning:
        return const Color(0xFFF7D02C);
      case CardKind.psychic:
        return const Color(0xFFF95587);
      case CardKind.fighting:
        return const Color(0xFFC22E28);
      case CardKind.darkness:
        return const Color(0xFF705746);
      case CardKind.metal:
        return const Color(0xFFB7B7CE);
      case CardKind.dragon:
        return const Color(0xFF6F35FC);
      case CardKind.colorless:
        return const Color(0xFFA8A77A);
      case CardKind.supporter:
      case CardKind.item:
      case CardKind.tool:
      case CardKind.stadium:
      case CardKind.fossil:
      case CardKind.unknown:
        return null;
    }
  }

  /// Icône d'un type de Dresseur ou de [CardKind.unknown] ; `null`
  /// pour les éléments, qui utilisent [color].
  IconData? get icon {
    switch (this) {
      case CardKind.supporter:
        return Icons.person_outline;
      case CardKind.item:
        return Icons.science_outlined;
      case CardKind.tool:
        return Icons.build_outlined;
      case CardKind.stadium:
        return Icons.location_city_outlined;
      case CardKind.fossil:
        return Icons.terrain_outlined;
      case CardKind.unknown:
        return Icons.help_outline;
      case CardKind.grass:
      case CardKind.fire:
      case CardKind.water:
      case CardKind.lightning:
      case CardKind.psychic:
      case CardKind.fighting:
      case CardKind.darkness:
      case CardKind.metal:
      case CardKind.dragon:
      case CardKind.colorless:
        return null;
    }
  }
}
