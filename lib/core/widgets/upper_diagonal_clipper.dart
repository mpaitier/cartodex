import 'package:flutter/widgets.dart';

/// Découpe le triangle situé au-dessus de la diagonale qui va du coin
/// haut gauche au coin bas droit : les coins haut gauche, haut droit
/// et bas droit.
///
/// Utilisé par [DiagonalGrayscaleSplit][diagonal_grayscale_split.dart]
/// pour ne griser que cette moitié du widget.
class UpperDiagonalClipper extends CustomClipper<Path> {
  const UpperDiagonalClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
  }

  /// La forme ne dépend que de la taille, déjà prise en compte par
  /// Flutter à chaque changement : rien d'autre à surveiller.
  @override
  bool shouldReclip(covariant UpperDiagonalClipper oldClipper) => false;
}