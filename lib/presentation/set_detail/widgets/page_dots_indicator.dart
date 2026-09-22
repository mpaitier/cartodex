import 'package:flutter/material.dart';

/// Indicateur des 3 volets de [CardGridPager][card_grid_pager.dart].
///
/// Plutôt que des points génériques, chaque volet garde son propre
/// glyphe (losange, rond, étoile) pour rappeler ce qu'il montre.
/// Celui du volet actif est agrandi et coloré ; les deux autres
/// restent petits et grisés, pour suggérer qu'on peut swiper sans
/// avoir à l'expliquer.
class PageDotsIndicator extends StatelessWidget {
  const PageDotsIndicator({required this.currentPage, super.key});

  /// Index du volet actif (0 = losange, 1 = tout, 2 = étoile).
  final int currentPage;

  static const _symbols = ['◆', '●', '★'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _symbols.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _symbols[i],
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