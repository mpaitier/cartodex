import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Bouton de la barre du haut du détail d'un set qui ouvre le panneau
/// de filtres ([SetDetailFilterSheet][set_detail_filter_sheet.dart]).
///
/// Une pastille indique le nombre de filtres actifs, pour qu'une grille
/// filtrée ne passe pas pour une grille incomplète une fois le panneau
/// refermé. Composant purement visuel : l'appui remonte via
/// [onPressed].
class SetDetailFilterAction extends StatelessWidget {
  const SetDetailFilterAction({
    required this.activeFilterCount,
    required this.onPressed,
    super.key,
  });

  final int activeFilterCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: context.l10n.commonFilters,
      icon: Badge(
        isLabelVisible: activeFilterCount > 0,
        label: Text('$activeFilterCount'),
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
