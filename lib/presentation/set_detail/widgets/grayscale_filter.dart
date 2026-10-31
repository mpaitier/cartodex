import 'package:flutter/material.dart';

/// Applique un filtre noir et blanc sur [child] quand [enabled] est
/// vrai ; le rend tel quel sinon.
///
/// Utilise la luminance perceptuelle (coefficients Rec. 709) plutôt
/// qu'une simple moyenne des canaux, pour que les niveaux de gris
/// restent fidèles à la luminosité réelle de l'illustration.
///
/// Composant purement visuel et sans état : réutilisable pour
/// n'importe quel widget, pas seulement les tuiles de cartes.
class GrayscaleFilter extends StatelessWidget {
  const GrayscaleFilter({
    required this.enabled,
    required this.child,
    super.key,
  });

  final bool enabled;
  final Widget child;

  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ColorFiltered(colorFilter: _grayscale, child: child);
  }
}