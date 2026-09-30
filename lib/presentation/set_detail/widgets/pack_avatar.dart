import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/pocket_cards_image_slug.dart';

/// Icône ronde d'un booster (utilisée par
/// [PackFilterBar][pack_filter_bar.dart] et par la liste des
/// boosters prioritaires des statistiques).
///
/// pocketcards.net nomme ses icônes de booster avec le nom du set
/// suivi de celui du booster : [setName] et [packName] sont donc
/// tous deux nécessaires (ex: "Genetic Apex" + "Mewtwo" →
/// `.../boosters/genetic-apex-mewtwo.webp`, voir
/// [PocketCardsImageSlug.fromBoosterName]). Retombe sur une icône
/// générique tant que le chargement échoue — voir [AppLogger], qui
/// signale chaque échec pour repérer les noms mal gérés par la
/// conversion générique.
class PackAvatar extends StatelessWidget {
  const PackAvatar({
    required this.setName,
    required this.packName,
    this.radius = 12,
    super.key,
  });

  final String setName;
  final String packName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = '${AppConstants.pocketCardsBoosterImageBaseUrl}/'
        '${PocketCardsImageSlug.fromBoosterName(setName, packName)}.webp';
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