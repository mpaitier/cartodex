import 'package:flutter/widgets.dart';

/// Filtres de couleur partagés, à appliquer avec `ColorFiltered`.
abstract class AppColorFilters {
  /// Niveaux de gris pondérés par la luminance perçue (coefficients
  /// Rec. 709), transparence conservée. Sert à griser les cartes non
  /// possédées, entièrement ou à moitié (voir
  /// `DiagonalGrayscaleSplit`).
  static const ColorFilter grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}