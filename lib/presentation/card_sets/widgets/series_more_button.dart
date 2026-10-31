import 'package:flutter/material.dart';

/// Bouton "Toutes les séries" en bout de
/// [SeriesFilterBar][series_filter_bar.dart] : ouvre
/// [SeriesPickerSheet][series_picker_sheet.dart]. Largeur fixe, pour
/// que les boutons de série gardent toute la place restante.
class SeriesMoreButton extends StatelessWidget {
  const SeriesMoreButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Toutes les séries',
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Icon(
            Icons.grid_view_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}