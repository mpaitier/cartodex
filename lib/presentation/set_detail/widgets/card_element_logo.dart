import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/card_kind.dart';

/// Logo officiel d'un élément de Pokémon (Plante, Feu...), repris de
/// pocketcards.net comme les images de cartes, les logos de set et les
/// icônes de booster, pour les puces du filtre par type.
///
/// Les logos sont préchargés dès l'ouverture du détail d'un set
/// ([precacheAll]) : quand le panneau de filtres s'ouvre, ils sont
/// déjà en mémoire et s'affichent d'emblée, sans fondu. S'ils ne le
/// sont pas encore, la place du logo reste vide le temps du
/// chargement plutôt que d'afficher un repère provisoire qui
/// changerait sous les yeux.
///
/// Si le logo est introuvable, [errorBuilder] prend sa place (dans la
/// puce : pastille de couleur et nom de l'élément), et l'échec est
/// signalé dans les logs.
///
/// [kind] doit être un élément ([CardKind.isElement]) : son nom
/// ("grass", "fire"...) est aussi celui du fichier sur le site.
class CardElementLogo extends StatelessWidget {
  const CardElementLogo({
    required this.kind,
    required this.errorBuilder,
    this.size = 22,
    super.key,
  });

  final CardKind kind;
  final WidgetBuilder errorBuilder;
  final double size;

  /// Dossier des logos d'éléments sur pocketcards.net (ex:
  /// `.../colors/grass.webp`). Gardé ici plutôt que dans
  /// `AppConstants` tant que ce seul widget s'en sert.
  static const String _baseUrl = 'https://pocketcards.net/images/colors';

  static String _urlFor(CardKind kind) => '$_baseUrl/${kind.name}.webp';

  /// Charge en mémoire les logos de tous les éléments, pour qu'ils
  /// s'affichent sans délai à l'ouverture du panneau de filtres. Un
  /// logo introuvable est simplement ignoré ici : [CardElementLogo]
  /// le signalera s'il doit l'afficher.
  static void precacheAll(BuildContext context) {
    for (final kind in CardKind.values.where((k) => k.isElement)) {
      precacheImage(
        CachedNetworkImageProvider(_urlFor(kind)),
        context,
        onError: (_, __) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _urlFor(kind),
      height: size,
      fit: BoxFit.contain,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder: (context, _) => SizedBox.square(dimension: size),
      errorWidget: (context, failedUrl, error) {
        AppLogger.log(
          'ERROR',
          "Logo d'élément introuvable : $failedUrl ($error)",
        );
        return errorBuilder(context);
      },
    );
  }
}
