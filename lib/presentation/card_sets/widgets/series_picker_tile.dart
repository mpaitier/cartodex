import 'package:flutter/material.dart';

import '../bloc/series_overview.dart';
import 'series_completion_indicator.dart';

/// Une série dans [SeriesPickerSheet][series_picker_sheet.dart] : sa
/// lettre en grand, son nombre de sets, et la complétion du compte
/// principal quand elle est connue.
class SeriesPickerTile extends StatelessWidget {
  const SeriesPickerTile({
    required this.overview,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SeriesOverview overview;
  final bool selected;
  final VoidCallback onTap;

  /// Pluriel français : "1 set", "2 sets".
  String get _setCountLabel {
    final count = overview.setCount;
    return count > 1 ? '$count sets' : '$count set';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.12)
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    overview.tab.label,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: selected ? colorScheme.primary : null,
                    ),
                  ),
                ),
              ),
              Text(_setCountLabel, style: theme.textTheme.bodySmall),
              if (overview.hasProgress) ...[
                const SizedBox(height: 4),
                SeriesCompletionIndicator(overview: overview),
              ],
            ],
          ),
        ),
      ),
    );
  }
}