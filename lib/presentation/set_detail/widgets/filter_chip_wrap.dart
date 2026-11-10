import 'package:flutter/material.dart';

/// Mise en page commune des barres de puces du panneau de filtres du
/// détail d'un set : les puces se suivent et passent à la ligne quand
/// la largeur manque, au lieu de défiler sur le côté. Toutes les
/// options restent visibles d'un coup d'œil.
///
/// Même interface que `ListView.builder` ([itemCount], [itemBuilder]),
/// pour que chaque barre n'ait qu'à décrire ses puces.
class FilterChipWrap extends StatelessWidget {
  const FilterChipWrap({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (var index = 0; index < itemCount; index++)
            itemBuilder(context, index),
        ],
      ),
    );
  }
}
