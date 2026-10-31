import 'package:flutter/material.dart';

import '../bloc/series_tab.dart';
import 'series_more_button.dart';
import 'series_tab_button.dart';

/// Menu flottant en bas d'écran pour choisir la série affichée.
///
/// [tabs] ne contient que les onglets "rapides"
/// (`CardSetsState.quickTabs`) : les séries les plus récentes, la
/// série sélectionnée et "Promo". La barre garde ainsi la même taille
/// quel que soit le nombre de séries. Quand [onMorePressed] est
/// fourni, un bouton en bout de barre donne accès à toutes les
/// séries.
///
/// Se rend invisible s'il n'y a rien à choisir (une seule série
/// connue).
class SeriesFilterBar extends StatelessWidget {
  const SeriesFilterBar({
    required this.tabs,
    required this.selectedKey,
    required this.onSelected,
    this.onMorePressed,
    super.key,
  });

  final List<SeriesTab> tabs;
  final String? selectedKey;
  final ValueChanged<String> onSelected;

  /// `null` quand toutes les séries tiennent déjà dans la barre : le
  /// bouton "Toutes les séries" n'est alors pas affiché.
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final morePressed = onMorePressed;
    if (tabs.length <= 1 && morePressed == null) {
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
          // IntrinsicHeight + stretch : le bouton "Toutes les séries"
          // prend la même hauteur que les boutons de série, sinon sa
          // zone de tap serait plus petite que la barre.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final tab in tabs)
                  Expanded(
                    child: SeriesTabButton(
                      tab: tab,
                      selected: tab.key == selectedKey,
                      onTap: () => onSelected(tab.key),
                    ),
                  ),
                if (morePressed != null) SeriesMoreButton(onPressed: morePressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}