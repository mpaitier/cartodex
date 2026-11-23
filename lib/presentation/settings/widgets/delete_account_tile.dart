import 'package:flutter/material.dart';

import '../../../domain/entities/app_user.dart';
import '../../../l10n/l10n.dart';
import '../../delete_account/widgets/delete_account_flow.dart';

/// Ligne « Supprimer le compte cloud », en rouge, sous la
/// déconnexion. Ouvre la popup de confirmation ([DeleteAccountFlow]).
class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = Theme.of(context).colorScheme.error;
    return ListTile(
      leading: Icon(Icons.delete_forever_outlined, color: color),
      title: Text(l10n.settingsDeleteAccount, style: TextStyle(color: color)),
      subtitle: Text(l10n.settingsDeleteAccountSubtitle),
      onTap: () => DeleteAccountFlow.start(context, user: user),
    );
  }
}
