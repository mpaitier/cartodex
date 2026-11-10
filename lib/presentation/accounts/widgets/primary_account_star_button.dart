import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Étoile d'une ligne de compte.
///
/// Pleine et jaune pour le compte principal, non interactive ; en
/// contour gris pour les autres, et cliquable : l'appui échange le
/// rôle avec le principal actuel (voir
/// [AccountsBloc][../bloc/accounts_bloc.dart]).
///
/// Composant purement visuel : l'appui remonte via [onPressed].
class PrimaryAccountStarButton extends StatelessWidget {
  const PrimaryAccountStarButton({
    required this.isPrimary,
    required this.onPressed,
    super.key,
  });

  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IconButton(
      onPressed: isPrimary ? null : onPressed,
      tooltip: isPrimary
          ? l10n.primaryAccountTooltip
          : l10n.setPrimaryAccountTooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        isPrimary ? Icons.star : Icons.star_border,
        color: isPrimary ? Colors.amber[700] : Colors.grey,
      ),
    );
  }
}
