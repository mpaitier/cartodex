import 'package:flutter/material.dart';

import '../../../domain/entities/card_element.dart';

/// Libellé et couleur affichés pour chaque élément de carte dans le
/// filtre par type. Gardés côté présentation : l'énumération du
/// domaine ne porte ni texte ni couleur d'interface.
///
/// Les couleurs reprennent la teinte habituelle de chaque type
/// Pokémon, assez saturée pour se distinguer sur une petite pastille.
extension CardElementStyle on CardElement {
  String get label {
    switch (this) {
      case CardElement.grass:
        return 'Plante';
      case CardElement.fire:
        return 'Feu';
      case CardElement.water:
        return 'Eau';
      case CardElement.lightning:
        return 'Électrique';
      case CardElement.psychic:
        return 'Psy';
      case CardElement.fighting:
        return 'Combat';
      case CardElement.darkness:
        return 'Obscurité';
      case CardElement.metal:
        return 'Métal';
      case CardElement.dragon:
        return 'Dragon';
      case CardElement.colorless:
        return 'Incolore';
      case CardElement.none:
        return 'Dresseur';
    }
  }

  Color get color {
    switch (this) {
      case CardElement.grass:
        return const Color(0xFF7AC74C);
      case CardElement.fire:
        return const Color(0xFFEE8130);
      case CardElement.water:
        return const Color(0xFF6390F0);
      case CardElement.lightning:
        return const Color(0xFFF7D02C);
      case CardElement.psychic:
        return const Color(0xFFF95587);
      case CardElement.fighting:
        return const Color(0xFFC22E28);
      case CardElement.darkness:
        return const Color(0xFF705746);
      case CardElement.metal:
        return const Color(0xFFB7B7CE);
      case CardElement.dragon:
        return const Color(0xFF6F35FC);
      case CardElement.colorless:
        return const Color(0xFFA8A77A);
      case CardElement.none:
        return const Color(0xFF9E9E9E);
    }
  }
}
