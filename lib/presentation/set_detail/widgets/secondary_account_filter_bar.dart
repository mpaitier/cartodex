import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/account.dart';

/// Barre horizontale de choix d'un compte secondaire précis, affichée
/// sous `OwnershipFilterBar` quand le filtre "secondaires" est actif :
/// "Tous" (union de tous les secondaires), puis un compte par puce.
///
/// [accounts] ne contient que les comptes qui ont au moins une carte
/// dans le set (voir `SetDetailState.secondaryAccountsWithCards`) :
/// une puce qui ne montrerait rien n'est jamais proposée.
///
/// Se rend invisible quand il y a moins de deux comptes à départager :
/// avec un seul, "Tous" et ce compte donneraient le même résultat.
class SecondaryAccountFilterBar extends StatelessWidget {
  const SecondaryAccountFilterBar({
    required this.accounts,
    required this.selectedAccountId,
    required this.onAccountSelected,
    super.key,
  });

  final List<Account> accounts;

  /// `null` = "Tous".
  final String? selectedAccountId;

  final ValueChanged<String?> onAccountSelected;

  @override
  Widget build(BuildContext context) {
    if (accounts.length <= 1) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: accounts.length + 1,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Tous'),
              selected: selectedAccountId == null,
              showCheckmark: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              onSelected: (_) => onAccountSelected(null),
            );
          }
          final account = accounts[index - 1];
          return ChoiceChip(
            avatar: const _Dot(),
            label: Text(account.name),
            selected: selectedAccountId == account.id,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onAccountSelected(account.id),
          );
        },
      ),
    );
  }
}

/// Pastille jaune, la couleur du badge des comptes secondaires.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: AppColors.ownedBySecondaryAccount,
        shape: BoxShape.circle,
      ),
    );
  }
}