import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Texte de l'heure à laquelle une synchronisation redevient possible
/// (ex: "Prochaine synchro possible à 14:32", ou "… demain à 09:05"
/// quand l'heure tombe le lendemain : la fenêtre de la limite ne dure
/// que 24 h, jamais plus loin).
///
/// L'heure suit le format de l'appareil (24 h ou AM/PM) via
/// `MaterialLocalizations`.
abstract class NextSyncTimeText {
  static String format(BuildContext context, DateTime next, DateTime now) {
    final l10n = context.l10n;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(next),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return DateUtils.isSameDay(next, now)
        ? l10n.syncNextAvailableToday(time)
        : l10n.syncNextAvailableTomorrow(time);
  }
}
