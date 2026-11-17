import 'package:flutter/painting.dart';

/// Taille du cache mémoire des images décodées, réglée au démarrage
/// (voir `main`).
///
/// Par défaut, Flutter ne garde que 100 Mo d'images décodées : à peine
/// un set et demi. En changeant d'écran, les illustrations sortaient
/// donc de la mémoire et devaient être relues sur le disque puis
/// redécodées, d'où le petit rond de chargement à chaque retour. Avec
/// les cartes décodées à taille réduite (voir `CardImageProvider`),
/// 256 Mo tiennent plusieurs sets entiers, logos et icônes en plus.
abstract final class MemoryImageCacheConfig {
  /// Nombre maximal d'images gardées en mémoire.
  static const int maximumImages = 3000;

  /// Mémoire maximale occupée par les images décodées.
  static const int maximumBytes = 256 << 20;

  /// À appeler une fois, après `WidgetsFlutterBinding.ensureInitialized`.
  static void apply() {
    PaintingBinding.instance.imageCache
      ..maximumSize = maximumImages
      ..maximumSizeBytes = maximumBytes;
  }
}
