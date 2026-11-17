import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/images/card_image_provider.dart';
import '../../../core/images/image_batch_precacher.dart';

/// Précharge les illustrations de [imageUrls] dès l'ouverture du
/// détail d'un set, par vagues (voir [ImageBatchPrecacher]), au lieu
/// d'attendre que chaque carte arrive à l'écran. Les cartes plus bas
/// dans la grille ou sur un autre volet sont ainsi déjà prêtes quand
/// on y arrive.
///
/// Les URL sont traitées dans l'ordre reçu : à l'appelant de mettre en
/// tête celles qu'on verra en premier. Une carte déjà en mémoire ne
/// coûte rien, une carte déjà sur le disque ne repasse pas par le
/// réseau.
///
/// Se contente d'afficher [child] : le préchargement est un effet de
/// bord, relancé seulement quand la liste d'URL change vraiment (pas à
/// chaque bascule de possession), et arrêté quand l'écran est quitté.
class CardImagesPreloader extends StatefulWidget {
  const CardImagesPreloader({
    required this.imageUrls,
    required this.child,
    super.key,
  });

  final List<String> imageUrls;
  final Widget child;

  @override
  State<CardImagesPreloader> createState() => _CardImagesPreloaderState();
}

class _CardImagesPreloaderState extends State<CardImagesPreloader> {
  /// Incrémenté à chaque nouveau préchargement et à la fermeture :
  /// une vague en cours compare sa génération à celle-ci pour savoir
  /// si elle doit s'arrêter.
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lancé ici plutôt que dans initState : precacheImage lit la
    // configuration d'image du contexte (densité de l'écran).
    if (_generation == 0) _start();
  }

  @override
  void didUpdateWidget(CardImagesPreloader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.imageUrls, widget.imageUrls)) _start();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  void _start() {
    final generation = ++_generation;
    if (widget.imageUrls.isEmpty) return;
    ImageBatchPrecacher.precache(
      context,
      [for (final url in widget.imageUrls) CardImageProvider.of(url)],
      isCancelled: () => generation != _generation,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
