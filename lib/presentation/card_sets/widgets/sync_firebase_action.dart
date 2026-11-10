import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/sync_result.dart';
import '../../../domain/services/sync_rate_limit.dart';
import '../../../l10n/l10n.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/view/login_page.dart';
import '../../sync/bloc/sync_bloc.dart';
import '../../sync/bloc/sync_event.dart';
import '../../sync/bloc/sync_state.dart';
import '../../sync/widgets/next_sync_time_text.dart';
import '../../sync/widgets/sync_now_menu_label.dart';

/// Action d'AppBar pour la synchronisation avec le compte
/// applicatif (Firebase).
///
/// Tant qu'aucun compte n'est connecté, ouvre [LoginPage]. Une fois
/// connecté, propose de synchroniser (délègue à [SyncBloc], qui
/// applique `SyncWithCloud` — comptes Pokémon et possession, règle
/// "possédée l'emporte toujours") ou de se déconnecter.
///
/// La synchronisation est limitée (voir `SyncRateLimit`) : l'entrée
/// du menu indique les synchronisations restantes, et se désactive
/// avec l'heure de la prochaine possible une fois la limite atteinte.
/// Le quota est recalculé à la connexion et à chaque ouverture du
/// menu.
class SyncFirebaseAction extends StatelessWidget {
  const SyncFirebaseAction({super.key});

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
          listener: (context, authState) => _requestQuota(context, authState),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final l10n = context.l10n;
          if (authState.status != AuthStatus.authenticated) {
            return IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              ),
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: l10n.signInToSyncTooltip,
            );
          }
          return BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              if (syncState.status == SyncStatus.syncing) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return PopupMenuButton<_SyncMenuAction>(
                icon: const Icon(Icons.cloud_done_outlined),
                tooltip: l10n.syncMenuTooltip,
                onOpened: () => _requestQuota(context, authState),
                onSelected: (action) =>
                    _onMenuAction(context, action, authState),
                itemBuilder: (context) {
                  final now = DateTime.now();
                  final quota = syncState.quota;
                  return [
                    PopupMenuItem(
                      value: _SyncMenuAction.sync,
                      enabled: quota == null || quota.isAvailableAt(now),
                      child: SyncNowMenuLabel(quota: quota, now: now),
                    ),
                    PopupMenuItem(
                      value: _SyncMenuAction.signOut,
                      child: Text(l10n.signOut),
                    ),
                  ];
                },
              );
            },
          );
        },
      ),
    );
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

  /// Bilan de la synchronisation (ex: "2 comptes récupérés, 14 cartes
  /// envoyées"), avec un pluriel propre à chaque langue.
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

  /// Recalcule le quota de l'utilisateur connecté, s'il y en a un.
  void _requestQuota(BuildContext context, AuthState authState) {
    final userId = authState.user?.uid;
    if (userId != null) {
      context.read<SyncBloc>().add(SyncQuotaRequested(userId));
    }
  }

  void _onMenuAction(
    BuildContext context,
    _SyncMenuAction action,
    AuthState authState,
  ) {
    switch (action) {
      case _SyncMenuAction.sync:
        final userId = authState.user?.uid;
        if (userId != null) {
          context.read<SyncBloc>().add(SyncRequested(userId));
        }
      case _SyncMenuAction.signOut:
        context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}

enum _SyncMenuAction { sync, signOut }
