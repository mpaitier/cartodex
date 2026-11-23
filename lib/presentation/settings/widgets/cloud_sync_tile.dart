import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/l10n.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../sync/bloc/sync_bloc.dart';
import '../../sync/bloc/sync_event.dart';
import '../../sync/bloc/sync_state.dart';
import '../../sync/widgets/sync_quota_text.dart';
import 'settings_progress_indicator.dart';

/// Ligne « Synchroniser maintenant » (comptes et possession avec le
/// cloud, voir [SyncBloc]).
///
/// Désactivée sans compte cloud connecté, pendant une synchronisation,
/// ou quand la limite est atteinte (voir `SyncRateLimit`). Le
/// sous-titre donne les synchronisations restantes ou l'heure de la
/// prochaine possible. Les bilans s'affichent via
/// `CloudSyncFeedbackListener`.
class CloudSyncTile extends StatelessWidget {
  const CloudSyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final syncState = context.watch<SyncBloc>().state;
    final l10n = context.l10n;
    final userId = authState.status == AuthStatus.authenticated
        ? authState.user?.uid
        : null;

    if (userId == null) {
      return ListTile(
        leading: const Icon(Icons.cloud_sync_outlined),
        title: Text(l10n.syncNow),
        subtitle: Text(l10n.settingsCloudSyncSignedOut),
        enabled: false,
      );
    }

    final now = DateTime.now();
    final quota = syncState.quota;
    final isSyncing = syncState.status == SyncStatus.syncing;
    final isAvailable = quota == null || quota.isAvailableAt(now);
    final detail = SyncQuotaText.format(context, quota, now);
    return ListTile(
      leading: const Icon(Icons.cloud_sync_outlined),
      title: Text(l10n.syncNow),
      subtitle: detail == null ? null : Text(detail),
      trailing: isSyncing ? const SettingsProgressIndicator() : null,
      enabled: !isSyncing && isAvailable,
      onTap: () => context.read<SyncBloc>().add(SyncRequested(userId)),
    );
  }
}
