import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Affiché quand aucun set n'a encore été synchronisé : invite à
/// lancer la première synchronisation plutôt que de montrer une
/// grille vide sans explication.
class CardSetsEmptyView extends StatelessWidget {
  const CardSetsEmptyView({required this.onSync, super.key});

  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_download_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.cardSetsEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSync,
              icon: const Icon(Icons.sync),
              label: Text(l10n.syncCatalog),
            ),
          ],
        ),
      ),
    );
  }
}