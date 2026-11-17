import 'package:flutter/widgets.dart';

/// Charge des images en mémoire par vagues, avant qu'elles ne soient
/// affichées.
///
/// Les images d'une vague sont demandées ensemble ; la vague suivante
/// ne part qu'une fois la précédente terminée (chargée ou en échec).
/// Ça évite de lancer des centaines de téléchargements d'un coup, qui
/// ralentiraient aussi les images affichées à l'écran.
///
/// Le préchargement s'arrête entre deux vagues dès que [isCancelled]
/// renvoie vrai, ou que [context] n'est plus monté (écran quitté).
/// Une image introuvable est ignorée : le widget qui l'affiche
/// signalera l'erreur lui-même.
abstract final class ImageBatchPrecacher {
  /// Taille d'une vague par défaut.
  static const int defaultBatchSize = 24;

  static Future<void> precache(
    BuildContext context,
    List<ImageProvider> providers, {
    required bool Function() isCancelled,
    int batchSize = defaultBatchSize,
  }) async {
    for (var start = 0; start < providers.length; start += batchSize) {
      if (isCancelled() || !context.mounted) return;
      final end = (start + batchSize).clamp(0, providers.length);
      await Future.wait([
        for (final provider in providers.sublist(start, end))
          precacheImage(provider, context, onError: (_, __) {}),
      ]);
    }
  }
}
