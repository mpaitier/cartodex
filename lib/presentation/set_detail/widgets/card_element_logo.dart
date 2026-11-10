import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/card_kind.dart';
import 'card_kind_style.dart';

/// Logo officiel d'un élément de Pokémon (Plante, Feu...), repris de
/// pocketcards.net comme les images de cartes, les logos de set et les
/// icônes de booster, pour les puces du filtre par type.
///
/// Tant que l'image charge, ou si elle est introuvable, une pastille
/// de la couleur de l'élément ([CardKindStyle.color]) prend sa place :
/// la puce reste lisible dans tous les cas. Un échec est signalé dans
/// les logs, comme pour les logos de set et les icônes de booster.
///
/// [kind] doit être un élément ([CardKind.isElement]) : son nom ("grass",
/// "fire"...) est aussi celui du fichier sur le site.
class CardElementLogo extends StatelessWidget {
  const CardElementLogo({required this.kind, this.size = 18, super.key});

  final CardKind kind;
  final double size;

  /// Dossier des logos d'éléments sur pocketcards.net (ex:
  /// `.../colors/grass.webp`). Gardé ici plutôt que dans
  /// `AppConstants` tant que ce seul widget s'en sert.
  static const String _baseUrl = 'https://pocketcards.net/images/colors';

  @override
  Widget build(BuildContext context) {
    final url = '$_baseUrl/${kind.name}.webp';
    return SizedBox.square(
      dimension: size,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (context, _) => _ColorDot(color: kind.color),
        errorWidget: (context, failedUrl, error) {
          AppLogger.log(
            'ERROR',
            "Logo d'élément introuvable : $failedUrl ($error)",
          );
          return _ColorDot(color: kind.color);
        },
      ),
    );
  }
}

/// Repli de [CardElementLogo] : pastille de la couleur de l'élément.
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color ?? Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
