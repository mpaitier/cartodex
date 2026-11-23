import 'package:flutter/widgets.dart';

import '../../../domain/entities/sync_quota.dart';
import '../../../l10n/l10n.dart';
import 'next_sync_time_text.dart';

/// Texte affiché sous « Synchroniser maintenant » : le nombre de
/// synchronisations restantes ou, limite atteinte, l'heure de la
/// prochaine possible. Un compte exempté voit "Synchros illimitées".
abstract class SyncQuotaText {
  /// `null` quand il n'y a rien à afficher : quota pas encore calculé,
  /// ou fenêtre de la limite déjà glissée depuis le calcul.
  ///
  /// [now] sert de référence pour savoir si la fenêtre a glissé.
  static String? format(BuildContext context, SyncQuota? quota, DateTime now) {
    if (quota == null) return null;
    final l10n = context.l10n;
    if (quota.isUnlimited) return l10n.syncUnlimited;
    final next = quota.nextAvailableAt;
    if (quota.remaining > 0 || next == null) {
      return l10n.syncRemaining(quota.remaining);
    }
    if (quota.isAvailableAt(now)) return null;
    return NextSyncTimeText.format(context, next, now);
  }
}
