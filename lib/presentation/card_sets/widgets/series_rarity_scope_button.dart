import 'package:flutter/material.dart';

import '../../../domain/entities/rarity_scope.dart';
import '../../stats/widgets/rarity_scope_icon.dart';

/// Bouton du bandeau de série : affiche le périmètre de raretés actif
/// (Σ, losange ou étoile) et passe au suivant à chaque appui — le même
/// cycle que le bouton de l'écran de statistiques
/// (`RarityScopeAction`).
///
/// Ne garde aucun état : le périmètre est global à l'app
/// (`RarityScopeCubit`), le même d'une série à l'autre et d'un écran à
/// l'autre.
class SeriesRarityScopeButton extends StatelessWidget {
  const SeriesRarityScopeButton({
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
      visualDensity: VisualDensity.compact,
      icon: RarityScopeIcon(
        scope: scope,
        totalColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
