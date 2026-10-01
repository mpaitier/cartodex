import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/ownership_filter.dart';

/// Barre horizontale de filtre par possession, à sélection unique :
/// toutes les cartes, celles du compte principal, celles des comptes
/// secondaires uniquement, ou celles qu'aucun compte ne possède.
///
/// Les pastilles reprennent les couleurs du badge de possession de
/// `CardGridItem` (violet : principal, jaune : secondaires, gris :
/// non possédées) pour que chaque puce se lise comme ce qu'elle
/// filtre.
///
/// Se rend invisible quand [availableFilters] n'offre aucun vrai
/// choix (moins de deux entrées — typiquement, aucun compte
/// principal n'existe encore).
class OwnershipFilterBar extends StatelessWidget {
  const OwnershipFilterBar({
    required this.availableFilters,
    required this.selectedFilter,
    required this.onFilterSelected,
    super.key,
  });

  final List<OwnershipFilter> availableFilters;
  final OwnershipFilter selectedFilter;
  final ValueChanged<OwnershipFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    if (availableFilters.length <= 1) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: availableFilters.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = availableFilters[index];
          return ChoiceChip(
            avatar: _dotFor(filter),
            label: Text(_labelFor(filter)),
            selected: filter == selectedFilter,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onFilterSelected(filter),
          );
        },
      ),
    );
  }

  static String _labelFor(OwnershipFilter filter) {
    switch (filter) {
      case OwnershipFilter.all:
        return 'Tout';
      case OwnershipFilter.primary:
        return 'Principal';
      case OwnershipFilter.secondary:
        return 'Secondaires';
      case OwnershipFilter.notOwned:
        return 'Manquantes';
    }
  }

  /// `null` pour "Tout" : pas de pastille, il ne représente aucun
  /// état de possession en particulier.
  static Widget? _dotFor(OwnershipFilter filter) {
    switch (filter) {
      case OwnershipFilter.all:
        return null;
      case OwnershipFilter.primary:
        return const _Dot(color: AppColors.ownedByPrimaryAccount);
      case OwnershipFilter.secondary:
        return const _Dot(color: AppColors.ownedBySecondaryAccount);
      case OwnershipFilter.notOwned:
        return const _Dot(color: Colors.black45);
    }
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}