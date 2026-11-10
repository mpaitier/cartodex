import 'package:flutter/material.dart';

import '../../../domain/entities/sync_quota.dart';
import '../../../l10n/l10n.dart';
import 'next_sync_time_text.dart';

/// Contenu de l'entrée "Synchroniser maintenant" du menu cloud : le
/// libellé, et en dessous le nombre de synchronisations restantes ou,
/// limite atteinte, l'heure de la prochaine possible.
///
/// Sans [quota] (pas encore calculé), seul le libellé s'affiche.
/// L'entrée elle-même est désactivée par l'appelant quand aucune
/// synchronisation n'est possible.
class SyncNowMenuLabel extends StatelessWidget {
  const SyncNowMenuLabel({required this.quota, required this.now, super.key});

  final SyncQuota? quota;

  /// Instant de référence pour savoir si la fenêtre a glissé depuis le
  /// calcul du quota.
  final DateTime now;

  String? _detail(BuildContext context) {
    final quota = this.quota;
    if (quota == null) return null;
    final next = quota.nextAvailableAt;
    if (quota.remaining > 0 || next == null) {
      return context.l10n.syncRemaining(quota.remaining);
    }
    if (quota.isAvailableAt(now)) return null;
    return NextSyncTimeText.format(context, next, now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = _detail(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.syncNow),
        if (detail != null)
          Text(
            detail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
