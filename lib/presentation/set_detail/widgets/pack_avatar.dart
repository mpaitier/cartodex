import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/pocket_cards_image_slug.dart';

/// Icône ronde d'un booster (utilisée par
/// [PackFilterBar][pack_filter_bar.dart]).
///
/// Chaque nom de booster est converti en URL d'image via
/// [PocketCardsImageSlug.fromPackName] (ex: "Mega Rising Blaziken" →
/// `.../boosters/mega-rising-blaziken.webp`). Retombe sur une icône
/// générique tant que le chargement échoue — voir [AppLogger], qui
/// signale chaque échec pour repérer les noms de booster mal gérés
/// par la conversion générique.
class PackAvatar extends StatelessWidget {
  const PackAvatar({required this.packName, this.radius = 12, super.key});

  final String packName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = '${AppConstants.pocketCardsBoosterImageBaseUrl}/'
        '${PocketCardsImageSlug.fromPackName(packName)}.webp';
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.black12,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, _) => const SizedBox.shrink(),
          errorWidget: (context, failedUrl, error) {
            AppLogger.log(
              'ERROR',
              'Icône de booster introuvable : $failedUrl ($error)',
            );
            return const Icon(Icons.inventory_2_outlined, size: 14);
          },
        ),
      ),
    );
  }
}