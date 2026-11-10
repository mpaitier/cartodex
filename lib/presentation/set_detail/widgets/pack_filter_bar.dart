import 'package:flutter/material.dart';

import '../../../core/utils/pack_display_name.dart';
import 'pack_avatar.dart';

/// Barre horizontale de filtre par booster, avec un choix "Tous"
/// systématique en tête. Comme les autres barres du panneau de
/// filtres, les puces n'affichent pas de coche : la puce choisie se
/// reconnaît à sa couleur.
///
/// [setName] est nécessaire pour retrouver l'icône de chaque booster
/// (voir [PackAvatar]), et pour retirer le nom de l'extension quand le
/// référentiel l'a répété dans celui du booster (voir
/// [PackDisplayName]).
///
/// Se rend invisible quand le set n'a qu'un seul booster (ou
/// aucun) : le filtre n'apporterait rien dans ce cas.
class PackFilterBar extends StatelessWidget {
  const PackFilterBar({
    required this.setName,
    required this.packs,
    required this.selectedPack,
    required this.onPackSelected,
    super.key,
  });

  final String setName;
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
              showCheckmark: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              onSelected: (_) => onPackSelected(null),
            );
          }
          final pack = packs[index - 1];
          return ChoiceChip(
            avatar: PackAvatar(setName: setName, packName: pack),
            label: Text(PackDisplayName.of(setName, pack)),
            selected: selectedPack == pack,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onPackSelected(pack),
          );
        },
      ),
    );
  }
}