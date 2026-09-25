import 'package:flutter/material.dart';

/// Indicateur des 3 volets de [CardGridPager][card_grid_pager.dart].
///
/// Trois losanges — plutôt que des points génériques, pour
/// reprendre le symbole déjà utilisé pour la rareté ailleurs dans
/// l'app — celui du volet actif agrandi et coloré.
class PageDotsIndicator extends StatelessWidget {
  const PageDotsIndicator({required this.currentPage, super.key});

  /// Index du volet actif (0 = losange, 1 = tout, 2 = étoile).
  final int currentPage;

  static const _pageCount = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _pageCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '◆',
              style: TextStyle(
                fontSize: i == currentPage ? 16 : 11,
                color: i == currentPage
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
            ),
          ),
      ],
    );
  }
}