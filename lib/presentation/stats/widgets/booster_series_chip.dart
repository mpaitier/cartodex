import 'package:flutter/material.dart';

/// Une puce du [BoosterSeriesSelector][booster_series_selector.dart] :
/// "Toutes" ou le libellé d'une série ("A", "B", "Deluxe"…), mise en
/// avant quand [selected] est vrai.
class BoosterSeriesChip extends StatelessWidget {
  const BoosterSeriesChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? theme.colorScheme.primary : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      // Une puce déjà sélectionnée ne se désélectionne pas : on passe
      // par "Toutes" pour retirer le filtre.
      onSelected: (_) {
        if (!selected) onSelected();
      },
    );
  }
}
