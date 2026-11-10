import 'package:flutter/material.dart';

/// Une rubrique du panneau de filtres du détail d'un set : un titre
/// (ex: "Rareté") au-dessus de sa barre de puces.
///
/// La rubrique entière est masquée quand [visible] est faux, pour ne
/// pas laisser un titre au-dessus d'une barre vide (les barres de puces
/// se masquent d'elles-mêmes quand elles n'ont rien à proposer).
class FilterSheetSection extends StatelessWidget {
  const FilterSheetSection({
    required this.title,
    required this.child,
    this.visible = true,
    super.key,
  });

  final String title;
  final Widget child;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        child,
      ],
    );
  }
}
