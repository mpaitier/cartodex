import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../card_sets/widgets/card_set_logo.dart';

/// Case sélectionnable du filtre par extension : le logo du set dans un
/// cadre arrondi, épaissi et dans la couleur principale du thème quand
/// il est choisi. Le nom du set apparaît en infobulle.
///
/// Mêmes dimensions que les cases d'aperçu de la liste des comptes,
/// pour qu'on y reconnaisse les mêmes logos. Composant purement
/// visuel : l'appui remonte via [onTap].
class SetFilterTile extends StatelessWidget {
  const SetFilterTile({
    required this.set,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final CardSet set;
  final bool selected;
  final VoidCallback onTap;

  static const double _width = 56;
  static const double _height = 38;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: set.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: _width,
          height: _height,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : null,
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CardSetLogo(url: set.logoUrl),
          ),
        ),
      ),
    );
  }
}
