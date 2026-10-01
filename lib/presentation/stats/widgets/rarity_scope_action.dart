import 'package:flutter/material.dart';

import '../../../domain/entities/rarity_scope.dart';

/// Action d'AppBar qui indique le périmètre de raretés des
/// statistiques et le fait passer au suivant à chaque appui :
/// rond (toutes raretés) → losange → étoile → rond.
///
/// Le symbole affiché est celui du périmètre actif ; le tooltip le
/// nomme explicitement.
class RarityScopeAction extends StatelessWidget {
  const RarityScopeAction({
    required this.scope,
    required this.onPressed,
    super.key,
  });

  final RarityScope scope;
  final VoidCallback onPressed;

  static String _symbolFor(RarityScope scope) {
    switch (scope) {
      case RarityScope.all:
        return '●';
      case RarityScope.diamond:
        return '◆';
      case RarityScope.star:
        return '★';
    }
  }

  static String _labelFor(RarityScope scope) {
    switch (scope) {
      case RarityScope.all:
        return 'toutes les raretés';
      case RarityScope.diamond:
        return 'losanges';
      case RarityScope.star:
        return 'étoiles';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Raretés : ${_labelFor(scope)}',
      icon: Text(
        _symbolFor(scope),
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }
}