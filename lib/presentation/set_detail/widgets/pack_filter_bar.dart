import 'package:flutter/material.dart';

/// Barre horizontale de filtre par booster, avec un choix "Tous"
/// systématique en tête.
///
/// Se rend invisible quand le set n'a qu'un seul booster (ou
/// aucun) : le filtre n'apporterait rien dans ce cas.
class PackFilterBar extends StatelessWidget {
  const PackFilterBar({
    required this.packs,
    required this.selectedPack,
    required this.onPackSelected,
    super.key,
  });

  final List<String> packs;
  final String? selectedPack;
  final ValueChanged<String?> onPackSelected;

  @override
  Widget build(BuildContext context) {
    if (packs.length <= 1) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: packs.length + 1,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Tous'),
              selected: selectedPack == null,
              onSelected: (_) => onPackSelected(null),
            );
          }
          final pack = packs[index - 1];
          return ChoiceChip(
            label: Text(pack),
            selected: selectedPack == pack,
            onSelected: (_) => onPackSelected(pack),
          );
        },
      ),
    );
  }
}