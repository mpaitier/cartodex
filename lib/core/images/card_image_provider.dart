import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

import 'app_image_cache_manager.dart';

/// Source d'image d'une illustration de carte, la même pour
/// l'affichage dans la grille et pour le préchargement (voir
/// `CardImagesPreloader`).
///
/// Les deux doivent produire exactement le même fournisseur : le cache
/// mémoire de Flutter range les images par fournisseur, et une image
/// préchargée avec un autre réglage serait simplement rechargée à
/// l'affichage.
///
/// L'image est décodée à [decodeWidth] pixels de large, au lieu de sa
/// taille d'origine : une tuile de la grille ne fait guère plus de
/// 120 points de large, soit environ 360 pixels sur un écran à forte
/// densité. Chaque carte prend ainsi bien moins de place en mémoire,
/// et beaucoup plus de cartes y tiennent en même temps.
abstract final class CardImageProvider {
  /// Largeur de décodage, en pixels physiques.
  static const int decodeWidth = 360;

  static ImageProvider of(String url) {
    return ResizeImage(
      CachedNetworkImageProvider(
        url,
        cacheManager: AppImageCacheManager.instance,
      ),
      width: decodeWidth,
    );
  }
}
