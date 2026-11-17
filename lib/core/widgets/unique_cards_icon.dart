import 'package:flutter/material.dart';

/// Pictogramme des cartes uniques d'un compte, celles qu'aucun autre
/// compte ne possède : une empreinte digitale, propre à une seule
/// personne.
///
/// Partagé par le bouton du profil d'un compte secondaire et par la
/// puce du détail d'un set, pour que la même idée ait partout le même
/// dessin. Changer de pictogramme se fait ici seulement.
class UniqueCardsIcon extends StatelessWidget {
  const UniqueCardsIcon({this.size, this.color, super.key});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.fingerprint, size: size, color: color);
  }
}
