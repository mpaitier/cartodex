import 'package:flutter/widgets.dart';

import 'upper_diagonal_clipper.dart';

/// Affiche [child] coupé en deux par la diagonale haut gauche - bas
/// droit : la moitié haute en niveaux de gris, la moitié basse
/// normale.
///
/// [child] est rendu deux fois l'un sur l'autre (la copie du dessus
/// passe par un filtre gris puis est découpée par
/// [UpperDiagonalClipper]). C'est plus léger qu'un `BackdropFilter`
/// par tuile, qui coûterait cher dans une grille de plusieurs
/// dizaines de cartes. [child] ne doit donc pas porter de
/// `GlobalKey`, et doit se contenter de dessiner : un widget qui
/// déclenche un effet de bord à la construction (log, requête) le
/// ferait deux fois.
class DiagonalGrayscaleSplit extends StatelessWidget {
  const DiagonalGrayscaleSplit({required this.child, super.key});

  final Widget child;

  /// Niveaux de gris pondérés par la luminance perçue (coefficients
  /// Rec. 709), transparence conservée.
  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        ClipPath(
          clipper: const UpperDiagonalClipper(),
          child: ColorFiltered(colorFilter: _grayscale, child: child),
        ),
      ],
    );
  }
}