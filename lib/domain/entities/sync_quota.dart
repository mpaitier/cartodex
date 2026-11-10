import 'package:equatable/equatable.dart';

/// Ce qu'il reste de synchronisations cloud à un compte applicatif sur
/// la période en cours (voir `SyncRateLimit`).
class SyncQuota extends Equatable {
  const SyncQuota({required this.remaining, this.nextAvailableAt});

  /// Synchronisations encore possibles tout de suite, jamais négatif.
  final int remaining;

  /// Moment où une synchronisation redevient possible, quand
  /// [remaining] vaut 0 ; `null` sinon.
  final DateTime? nextAvailableAt;

  /// Vrai si une synchronisation est permise à l'instant [now]. Le
  /// quota peut avoir été calculé un peu plus tôt : passé
  /// [nextAvailableAt], la fenêtre a glissé et une synchronisation
  /// s'est libérée, même sans recalcul.
  bool isAvailableAt(DateTime now) {
    if (remaining > 0) return true;
    final next = nextAvailableAt;
    return next != null && !now.isBefore(next);
  }

  @override
  List<Object?> get props => [remaining, nextAvailableAt];
}
