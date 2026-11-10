import 'package:cartodex/domain/entities/sync_quota.dart';
import 'package:cartodex/domain/services/sync_rate_limit.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 11, 10, 12);

DateTime _hoursAgo(num hours) =>
    _now.subtract(Duration(minutes: (hours * 60).round()));

void main() {
  group('SyncRateLimit.quotaFor', () {
    test('sans historique, tout le quota est disponible', () {
      expect(
        SyncRateLimit.quotaFor(const [], _now),
        const SyncQuota(remaining: SyncRateLimit.maxSyncs),
      );
    });

    test('chaque synchro des dernières 24 h consomme le quota', () {
      final quota = SyncRateLimit.quotaFor([_hoursAgo(1), _hoursAgo(5)], _now);
      expect(quota.remaining, 2);
      expect(quota.nextAvailableAt, isNull);
    });

    test('une synchro de plus de 24 h ne compte plus', () {
      final quota = SyncRateLimit.quotaFor(
        [_hoursAgo(25), _hoursAgo(24), _hoursAgo(2), _hoursAgo(1)],
        _now,
      );
      expect(quota.remaining, 2);
    });

    test('limite atteinte : prochaine synchro 24 h après la plus ancienne',
        () {
      final oldest = _hoursAgo(10);
      final quota = SyncRateLimit.quotaFor(
        [_hoursAgo(1), oldest, _hoursAgo(3), _hoursAgo(6)],
        _now,
      );
      expect(quota.remaining, 0);
      expect(quota.nextAvailableAt, oldest.add(SyncRateLimit.window));
    });

    test('au-delà de la limite, il faut que assez de synchros expirent',
        () {
      // 5 synchros dans la fenêtre : les deux plus anciennes doivent
      // sortir pour qu'une place se libère.
      final second = _hoursAgo(9);
      final quota = SyncRateLimit.quotaFor(
        [_hoursAgo(10), second, _hoursAgo(8), _hoursAgo(7), _hoursAgo(6)],
        _now,
      );
      expect(quota.remaining, 0);
      expect(quota.nextAvailableAt, second.add(SyncRateLimit.window));
    });

    test('une date future (horloge reculée) est ignorée', () {
      final quota = SyncRateLimit.quotaFor(
        [_now.add(const Duration(hours: 3)), _hoursAgo(1)],
        _now,
      );
      expect(quota.remaining, SyncRateLimit.maxSyncs - 1);
    });
  });

  group('SyncRateLimit.recent', () {
    test('garde la fenêtre, triée de la plus ancienne à la plus récente',
        () {
      expect(
        SyncRateLimit.recent([_hoursAgo(1), _hoursAgo(30), _hoursAgo(4)], _now),
        [_hoursAgo(4), _hoursAgo(1)],
      );
    });
  });

  group('SyncQuota.isAvailableAt', () {
    test('disponible tant qu’il reste des synchros', () {
      expect(const SyncQuota(remaining: 1).isAvailableAt(_now), isTrue);
    });

    test('indisponible avant la prochaine heure, disponible ensuite', () {
      final next = _now.add(const Duration(hours: 2));
      final quota = SyncQuota(remaining: 0, nextAvailableAt: next);
      expect(quota.isAvailableAt(_now), isFalse);
      expect(quota.isAvailableAt(next), isTrue);
    });
  });
}
