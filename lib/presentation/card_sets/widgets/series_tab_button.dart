import 'package:flutter/material.dart';

import '../bloc/series_tab.dart';

/// Un bouton de série dans [SeriesFilterBar][series_filter_bar.dart],
/// mis en avant quand [selected] est vrai.
class SeriesTabButton extends StatelessWidget {
  const SeriesTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SeriesTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          tab.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected ? theme.colorScheme.primary : null,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}