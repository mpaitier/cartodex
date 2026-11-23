import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../auth/view/login_page.dart';

/// Ligne affichée quand aucun compte cloud n'est connecté : ouvre
/// [LoginPage], qui se referme d'elle-même une fois connecté.
class CloudSignInTile extends StatelessWidget {
  const CloudSignInTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.login),
      title: Text(l10n.loginSubmitSignIn),
      subtitle: Text(l10n.settingsCloudSignInSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      ),
    );
  }
}
