import '../entities/sync_quota.dart';

/// Règle de limitation des synchronisations cloud : au plus
/// [maxSyncs] synchronisations réussies sur une fenêtre glissante de
/// [window], par compte applicatif.
///
/// Fonctions pures, sans horloge : l'instant courant est toujours
/// passé en paramètre, pour que la règle se teste sans attendre.
///
/// La limite protège le quota Firestore du projet contre une
/// synchronisation lancée en boucle. Elle est appliquée par l'app sur
/// l'appareil (historique local, voir `UserPreferencesRepository`) :
/// elle ne résiste pas à une réinstallation ou à un changement d'heure
/// volontaire, ce qui suffit pour un usage normal.
abstract class SyncRateLimit {
  static const int maxSyncs = 4;
  static const Duration window = Duration(hours: 24);

  /// Synchronisations de [history] encore dans la fenêtre à l'instant
  /// [now], de la plus ancienne à la plus récente.
  ///
  /// Une date postérieure à [now] (horloge de l'appareil reculée
  /// depuis) est écartée : elle bloquerait sinon les synchronisations
  /// jusqu'à ce que l'heure la rattrape.
  static List<DateTime> recent(Iterable<DateTime> history, DateTime now) {
    final windowStart = now.subtract(window);
    return history
        .where((sync) => sync.isAfter(windowStart) && !sync.isAfter(now))
        .toList()
      ..sort();
  }

  /// Quota restant à l'instant [now] d'après [history]. Quand tout est
  /// consommé, la prochaine synchronisation est possible une fois la
  /// plus ancienne sortie de la fenêtre.
  static SyncQuota quotaFor(Iterable<DateTime> history, DateTime now) {
    final inWindow = recent(history, now);
    final remaining = maxSyncs - inWindow.length;
    if (remaining > 0) return SyncQuota(remaining: remaining);
    return SyncQuota(
      remaining: 0,
      nextAvailableAt: inWindow[inWindow.length - maxSyncs].add(window),
    );
  }
}
