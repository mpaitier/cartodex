import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../accounts/view/accounts_page.dart';

/// Ligne « Comptes TCG Pocket » : ouvre l'écran des comptes de jeu
/// (principal et secondaires). La progression de l'accueil est
/// recalculée en quittant les paramètres, voir `CardSetsPage`.
class TcgpAccountsTile extends StatelessWidget {
  const TcgpAccountsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.people_alt_outlined),
      title: Text(l10n.settingsTcgpAccounts),
      subtitle: Text(l10n.settingsTcgpAccountsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AccountsPage()),
      ),
    );
  }
}
