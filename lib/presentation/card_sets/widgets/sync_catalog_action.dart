import 'package:flutter/material.dart';

/// Action d'AppBar déclenchant la synchronisation du référentiel.
///
/// Se transforme en indicateur de chargement pendant la
/// synchronisation, pour empêcher un déclenchement concurrent et
/// donner un retour visuel immédiat.
class SyncCatalogAction extends StatelessWidget {
  const SyncCatalogAction({
    required this.isSyncing,
    required this.onPressed,
    super.key,
  });

  final bool isSyncing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSyncing) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.sync),
      tooltip: 'Synchroniser le référentiel',
    );
  }
}