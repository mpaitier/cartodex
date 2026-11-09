import 'package:flutter/material.dart';

import '../../../domain/entities/rarity_scope.dart';
import 'rarity_scope_icon.dart';

/// Action d'AppBar qui indique le périmètre de raretés des
/// statistiques et le fait passer au suivant à chaque appui :
/// Σ (toutes raretés) → losange → étoile → Σ.
///
/// Le symbole affiché est celui du périmètre actif
/// ([RarityScopeIcon]) ; le tooltip le nomme explicitement.
class RarityScopeAction extends StatelessWidget {
  const RarityScopeAction({
    required this.scope,
    required this.onPressed,
    super.key,
  });

  final RarityScope scope;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Raretés : ${RarityScopeIcon.labelFor(scope)}',
      icon: RarityScopeIcon(scope: scope, totalColor: Colors.white),
    );
  }
}
