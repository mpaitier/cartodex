import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Bandeau affiché en haut du détail d'un set quand celui-ci est
/// restreint aux cartes d'un compte secondaire (voir
/// `SetDetailState.ownerFilterAccountId`) : rappelle pourquoi seules
/// certaines cartes sont visibles. Même flèche jaune que le badge de
/// possession des comptes secondaires.
class OwnerFilterBanner extends StatelessWidget {
  const OwnerFilterBanner({required this.accountName, super.key});

  final String accountName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.ownedBySecondaryAccount.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.arrow_upward, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cartes possédées par $accountName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}