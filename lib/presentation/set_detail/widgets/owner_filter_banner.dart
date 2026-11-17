import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/l10n.dart';

/// Bandeau affiché en haut du détail d'un set quand celui-ci est
/// restreint aux cartes d'un compte secondaire (voir
/// `SetDetailState.ownerFilterAccountId`) : rappelle pourquoi seules
/// certaines cartes sont visibles. Même flèche jaune que le badge de
/// possession des comptes secondaires.
///
/// [trailing], quand fourni, s'affiche à droite du texte : la puce des
/// cartes uniques du compte (`UniqueCardsFilterChip`), le panneau de
/// filtres ne proposant pas de filtre de possession sur cet écran.
class OwnerFilterBanner extends StatelessWidget {
  const OwnerFilterBanner({
    required this.accountName,
    this.trailing,
    super.key,
  });

  final String accountName;
  final Widget? trailing;

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
              context.l10n.ownerFilterBanner(accountName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}