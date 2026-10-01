import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_logger.dart';

/// Logo du set, avec repli sur une icône générique tant que [url]
/// est `null` ou que le chargement échoue.
///
/// [url] est reconstruit depuis pocketcards.net à partir du nom du
/// set (voir `CardSetModel.fromJson` et `PocketCardsImageSlug`),
/// sans le suffixe `.webp` — ajouté ici, comme pour les cartes,
/// pour garder un seul endroit où l'extension de fichier est
/// décidée. Les logs (voir [AppLogger]) restent en place : INFO au
/// moment de la construction de l'URL, ERROR si le chargement
/// échoue (utile pour repérer les noms de set à ponctuation
/// inhabituelle que la conversion générique gère mal).
class CardSetLogo extends StatelessWidget {
  const CardSetLogo({required this.url, super.key});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) {
      return const ColoredBox(
        color: Colors.black12,
        child: Icon(Icons.style_outlined),
      );
    }
    final fullUrl = '$url.webp';
    AppLogger.log('INFO', 'Logo de set : $fullUrl');
    return ColoredBox(
      color: Colors.black12,
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        fit: BoxFit.contain,
        placeholder: (context, _) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, failedUrl, error) {
          AppLogger.log('ERROR', 'Logo de set introuvable : $failedUrl ($error)');
          return const Icon(Icons.broken_image_outlined);
        },
      ),
    );
  }
}