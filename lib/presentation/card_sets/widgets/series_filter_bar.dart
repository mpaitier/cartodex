import 'package:flutter/material.dart';

import '../bloc/card_sets_state.dart';

/// Menu flottant en bas d'écran pour filtrer les sets par série.
///
/// Prend toute la largeur disponible (un onglet par série, répartis
/// à parts égales), plutôt qu'une rangée de puces qu'il faudrait
/// faire défiler. Se rend invisible s'il n'y a rien à filtrer (une
/// seule série connue).
class SeriesFilterBar extends StatelessWidget {
  const SeriesFilterBar({
    required this.tabs,
    required this.selectedKey,
    required this.onSelected,
    super.key,
  });

  final List<SeriesTab> tabs;
  final String? selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (tabs.length <= 1) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          elevation: 4,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              for (final tab in tabs)
                Expanded(
                  child: _SeriesTabButton(
                    tab: tab,
                    selected: tab.key == selectedKey,
                    onTap: () => onSelected(tab.key),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeriesTabButton extends StatelessWidget {
  const _SeriesTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
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