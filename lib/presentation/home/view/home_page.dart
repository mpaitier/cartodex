import 'package:flutter/material.dart';

import '../../../core/widgets/app_scaffold.dart';

/// Écran d'accueil temporaire. Sera remplacé par la vue de
/// collection une fois les couches domaine et data en place.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Cartodex',
      body: Center(
        child: Text('Les fondations sont posées. La suite arrive bientôt.'),
      ),
    );
  }
}
