import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache disque de toutes les images distantes de l'app (cartes, logos
/// de sets, icônes de boosters et d'éléments).
///
/// Le cache par défaut de `cached_network_image` ne garde que 200
/// fichiers : bien moins que les cartes du référentiel. Les plus
/// anciennes étaient donc effacées au fil de la navigation, puis
/// retéléchargées au prochain passage. Ici, la limite couvre largement
/// tout le référentiel, et une image reste valable un an : une
/// illustration publiée ne change pas.
///
/// À passer en `cacheManager` de chaque `CachedNetworkImage` et de
/// chaque `CachedNetworkImageProvider`, pour que toutes les images
/// partagent le même cache.
class AppImageCacheManager extends CacheManager {
  AppImageCacheManager._()
      : super(
          Config(
            _key,
            stalePeriod: const Duration(days: 365),
            maxNrOfCacheObjects: 10000,
          ),
        );

  /// Nom du dossier de cache, distinct de celui par défaut pour ne pas
  /// hériter de sa limite de 200 fichiers.
  static const String _key = 'cartodexImageCache';

  /// Instance unique, partagée par toute l'app : deux gestionnaires
  /// sur le même dossier se marcheraient dessus.
  static final AppImageCacheManager instance = AppImageCacheManager._();
}
