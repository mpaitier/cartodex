import 'package:flutter/widgets.dart';

import '../theme/app_color_filters.dart';
import 'upper_diagonal_clipper.dart';

/// Affiche [child] coupé en deux par la diagonale haut gauche - bas
/// droit : la moitié haute en niveaux de gris, la moitié basse
/// normale.
///
/// [child] est rendu deux fois l'un sur l'autre (la copie du dessus
/// passe par [AppColorFilters.grayscale] puis est découpée par
/// [UpperDiagonalClipper]). C'est plus léger qu'un `BackdropFilter`
/// par tuile, qui coûterait cher dans une grille de plusieurs
/// dizaines de cartes. [child] ne doit donc pas porter de
/// `GlobalKey`, et doit se contenter de dessiner : un widget qui
/// déclenche un effet de bord à la construction (log, requête) le
/// ferait deux fois.
class DiagonalGrayscaleSplit extends StatelessWidget {
  const DiagonalGrayscaleSplit({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        ClipPath(
          clipper: const UpperDiagonalClipper(),
          child: ColorFiltered(
            colorFilter: AppColorFilters.grayscale,
            child: child,
          ),
        ),
      ],
    );
  }
}