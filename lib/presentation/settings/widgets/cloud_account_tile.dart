import 'package:flutter/material.dart';

import '../../../domain/entities/app_user.dart';
import '../../../l10n/l10n.dart';

/// Ligne d'information du compte cloud connecté : son adresse email
/// (ou, à défaut, son nom). Pas d'action au tap.
class CloudAccountTile extends StatelessWidget {
  const CloudAccountTile({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = user.email ?? user.displayName ?? l10n.settingsCloudSignedIn;
    return ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: Text(label),
      subtitle: Text(l10n.settingsCloudSignedIn),
    );
  }
}
