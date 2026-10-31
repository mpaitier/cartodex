import 'package:flutter/material.dart';

import '../bloc/series_overview.dart';
import 'series_picker_tile.dart';

/// Bottom sheet listant toutes les séries, ouverte par le bouton
/// "Toutes les séries" de [SeriesFilterBar][series_filter_bar.dart].
///
/// Ne connaît pas le Bloc : [show] renvoie simplement la clé de la
/// série choisie (ou `null` si la feuille est fermée sans choix), à
/// charge de l'écran de la transmettre.
class SeriesPickerSheet extends StatelessWidget {
  const SeriesPickerSheet({
    required this.overviews,
    required this.selectedKey,
    super.key,
  });

  final List<SeriesOverview> overviews;
  final String? selectedKey;

  static Future<String?> show(
    BuildContext context, {
    required List<SeriesOverview> overviews,
    required String? selectedKey,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SeriesPickerSheet(
        overviews: overviews,
        selectedKey: selectedKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toutes les séries',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 96,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: overviews.length,
                itemBuilder: (context, index) {
                  final overview = overviews[index];
                  return SeriesPickerTile(
                    overview: overview,
                    selected: overview.tab.key == selectedKey,
                    onTap: () => Navigator.of(context).pop(overview.tab.key),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}