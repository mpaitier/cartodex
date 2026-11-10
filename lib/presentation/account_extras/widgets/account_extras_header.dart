import 'package:flutter/material.dart';

import '../../../domain/entities/account_extras.dart';
import '../../../l10n/l10n.dart';
import '../../accounts/widgets/extra_counts_label.dart';

/// En-tête de la liste des sets : le total des cartes que le compte
/// secondaire possède en plus du principal, losanges et étoiles
/// séparés.
class AccountExtrasHeader extends StatelessWidget {
  const AccountExtrasHeader({required this.totals, super.key});

  final ExtraCounts totals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.accountExtrasHeader,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ExtraCountsLabel(counts: totals),
        ],
      ),
    );
  }
}