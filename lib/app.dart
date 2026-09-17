import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/home/view/home_page.dart';

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
      home: const HomePage(),
    );
  }
}
