import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/card_sets/view/card_sets_page.dart';

class CartodexApp extends StatelessWidget {
  const CartodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartodex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const CardSetsPage(),
    );
  }
}