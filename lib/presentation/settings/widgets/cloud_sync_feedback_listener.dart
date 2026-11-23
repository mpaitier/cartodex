import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sync_result.dart';
import '../../../domain/services/sync_rate_limit.dart';
import '../../../l10n/l10n.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../sync/bloc/sync_bloc.dart';
import '../../sync/bloc/sync_event.dart';
import '../../sync/bloc/sync_state.dart';
import '../../sync/widgets/next_sync_time_text.dart';

/// Enveloppe l'écran des paramètres pour tout ce que la
/// synchronisation cloud affiche hors de sa ligne :
///
/// - le bilan de chaque synchronisation en SnackBar (ex: "2 comptes
///   récupérés, 14 cartes envoyées"), l'erreur, ou la limite atteinte
///   avec l'heure de la prochaine ;
/// - le recalcul du quota à l'ouverture de l'écran et à chaque
///   changement de compte connecté, pour que `CloudSyncTile` affiche
///   un nombre restant à jour.
class CloudSyncFeedbackListener extends StatefulWidget {
  const CloudSyncFeedbackListener({required this.child, super.key});

  final Widget child;

  @override
  State<CloudSyncFeedbackListener> createState() =>
      _CloudSyncFeedbackListenerState();
}

class _CloudSyncFeedbackListenerState extends State<CloudSyncFeedbackListener> {
  @override
  void initState() {
    super.initState();
    _requestQuota(context.read<AuthBloc>().state);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Un message par changement de statut seulement : un simple
        // recalcul du quota ne doit pas réafficher le bilan.
        BlocListener<SyncBloc, SyncState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: _onSyncStateChanged,
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.user?.uid != current.user?.uid,
          listener: (_, authState) => _requestQuota(authState),
        ),
      ],
      child: widget.child,
    );
  }

  /// Recalcule le quota de l'utilisateur connecté, s'il y en a un.
  void _requestQuota(AuthState authState) {
    final userId = authState.user?.uid;
    if (userId != null) {
      context.read<SyncBloc>().add(SyncQuotaRequested(userId));
    }
  }

  void _onSyncStateChanged(BuildContext context, SyncState state) {
    final message = _messageFor(context, state);
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _messageFor(BuildContext context, SyncState state) {
    final l10n = context.l10n;
    switch (state.status) {
      case SyncStatus.success:
        final result = state.result;
        return result == null ? null : _successMessage(l10n, result);
      case SyncStatus.error:
        return state.errorMessage;
      case SyncStatus.quotaExceeded:
        final reached = l10n.syncQuotaReached(SyncRateLimit.maxSyncs);
        final next = state.quota?.nextAvailableAt;
        return next == null
            ? reached
            : '$reached ${NextSyncTimeText.format(context, next, DateTime.now())}';
      case SyncStatus.idle:
      case SyncStatus.syncing:
        return null;
    }
  }

  /// Bilan de la synchronisation, avec un pluriel propre à chaque
  /// langue.
  String _successMessage(AppLocalizations l10n, SyncResult result) {
    if (result.isEmpty) return l10n.syncUpToDate;
    final parts = <String>[
      if (result.accountsPulled > 0)
        l10n.syncAccountsPulled(result.accountsPulled),
      if (result.accountsPushed > 0)
        l10n.syncAccountsPushed(result.accountsPushed),
      if (result.cardsPulled > 0) l10n.syncCardsPulled(result.cardsPulled),
      if (result.cardsPushed > 0) l10n.syncCardsPushed(result.cardsPushed),
    ];
    return parts.join(', ');
  }
}
