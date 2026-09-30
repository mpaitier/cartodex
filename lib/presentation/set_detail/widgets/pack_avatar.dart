import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/pocket_cards_image_slug.dart';

/// Icône ronde d'un booster (utilisée par
/// [PackFilterBar][pack_filter_bar.dart] et par la liste des
/// boosters prioritaires des statistiques).
///
/// Deux formes d'URL sur pocketcards.net, selon le set :
/// - set à plusieurs boosters : nom du set suivi de celui du booster
///   (ex: "Genetic Apex" + "Mewtwo" →
///   `.../boosters/genetic-apex-mewtwo.webp`, voir
///   [PocketCardsImageSlug.fromBoosterName]) ;
/// - set à un seul booster : le nom du set seul (ex: "Ruler of the
///   Skies" → `.../boosters/ruler-of-the-skies.webp`). Dans ce cas
///   [packName] reste `null`.
///
/// Retombe sur une icône générique tant que le chargement échoue —
/// voir [AppLogger], qui signale chaque échec pour repérer les noms
/// mal gérés par la conversion générique.
class PackAvatar extends StatelessWidget {
  const PackAvatar({
    required this.setName,
    this.packName,
    this.radius = 12,
    super.key,
  });

  final String setName;

  /// `null` pour l'icône du booster unique d'un set à un seul
  /// booster (le nom du set suffit alors à former l'URL).
  final String? packName;

  final double radius;

  @override
  Widget build(BuildContext context) {
    final pack = packName;
    final slug = pack == null
        ? PocketCardsImageSlug.fromSetName(setName)
        : PocketCardsImageSlug.fromBoosterName(setName, pack);
    final url = '${AppConstants.pocketCardsBoosterImageBaseUrl}/$slug.webp';
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