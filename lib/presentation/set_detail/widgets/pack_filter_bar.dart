import 'package:flutter/material.dart';

import '../../../core/utils/pack_display_name.dart';
import '../../../l10n/l10n.dart';
import 'filter_chip_wrap.dart';
import 'pack_avatar.dart';

/// Barre de filtre par booster, avec un choix "Tous"
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
    return FilterChipWrap(
      itemCount: packs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ChoiceChip(
            label: Text(context.l10n.commonAll),
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
    );
  }
}