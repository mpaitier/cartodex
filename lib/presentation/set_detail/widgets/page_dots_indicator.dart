import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Indicateur des 3 volets de [CardGridPager][card_grid_pager.dart].
///
/// Trois losanges — plutôt que des points génériques, pour
/// reprendre le symbole déjà utilisé pour la rareté ailleurs dans
/// l'app — celui du volet actif agrandi et dans la couleur principale
/// du thème.
///
/// L'indicateur flotte au-dessus de la grille de cartes : il est posé
/// sur un fond gris aux bords arrondis
/// ([AppColors.translucentBadgeBackground], opacité de 80 %), pour
/// rester lisible quelle que soit l'illustration en dessous. Les
/// losanges des volets inactifs sont blancs atténués.
class PageDotsIndicator extends StatelessWidget {
  const PageDotsIndicator({required this.currentPage, super.key});

  /// Index du volet actif (0 = losange, 1 = tout, 2 = étoile).
  final int currentPage;

  static const _pageCount = 3;

  /// Opacité des losanges des volets inactifs.
  static const double _inactiveOpacity = 0.55;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.translucentBadgeBackground.withValues(
          alpha: AppColors.translucentBadgeOpacity,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _pageCount; i++)
              _PageDiamond(isActive: i == currentPage),
          ],
        ),
      ),
    );
  }
}

/// Un losange de l'indicateur. Hauteur fixe (celle du losange actif)
/// pour que le fond ne change pas de taille d'un volet à l'autre.
class _PageDiamond extends StatelessWidget {
  const _PageDiamond({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 20,
        child: Center(
          child: Text(
            '◆',
            style: TextStyle(
              fontSize: isActive ? 16 : 11,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(
                      alpha: PageDotsIndicator._inactiveOpacity,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
