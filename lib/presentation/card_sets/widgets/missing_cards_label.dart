import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Nombre de cartes qui manquent encore à la collection, en rouge
/// (ex: "12 manquantes").
///
/// [missing] compte les cartes que personne ne possède, ni le compte
/// principal ni un secondaire (voir `ProgressCount.missing`). Une
/// carte présente seulement sur un secondaire n'est donc pas
/// manquante : elle est déjà comptée dans le "(+Y)" jaune.
///
/// N'affiche rien quand il ne manque plus aucune carte.
class MissingCardsLabel extends StatelessWidget {
  const MissingCardsLabel({required this.missing, this.style, super.key});

  final int missing;

  /// Style de base ; le thème `bodySmall` par défaut.
  final TextStyle? style;

  /// Singulier pour une seule carte, comme le veut l'usage.
  String get _text => missing == 1 ? '1 manquante' : '$missing manquantes';

  @override
  Widget build(BuildContext context) {
    if (missing <= 0) return const SizedBox.shrink();
    final baseStyle = style ?? Theme.of(context).textTheme.bodySmall;
    return Text(
      _text,
      maxLines: 1,
      style: baseStyle?.copyWith(
        color: AppColors.missingCards,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
