import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Case à cocher de la popup de suppression : effacer aussi la
/// collection du téléphone (comptes de jeu et cartes cochées). Décochée
/// par défaut : l'app marche très bien sans compte cloud.
class DeleteLocalDataTile extends StatelessWidget {
  const DeleteLocalDataTile({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CheckboxListTile(
      value: value,
      onChanged: enabled ? (checked) => onChanged(checked ?? false) : null,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(l10n.deleteAccountLocalData),
      subtitle: Text(l10n.deleteAccountLocalDataSubtitle),
    );
  }
}
