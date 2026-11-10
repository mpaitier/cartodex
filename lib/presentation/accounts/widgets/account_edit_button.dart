import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Bouton crayon d'une ligne de compte : ouvre la popup de
/// modification du nom et du code ami
/// ([EditAccountDialog][edit_account_dialog.dart]).
///
/// Composant purement visuel : l'appui remonte via [onPressed].
class AccountEditButton extends StatelessWidget {
  const AccountEditButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: context.l10n.accountEditTooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.edit_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
