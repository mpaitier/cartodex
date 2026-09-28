import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/card_sets/view/card_sets_page.dart';

class CartodexApp extends StatelessWidget {
  const CartodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc est fourni ici, à la racine : c'est un état global de
    // l'app (le compte applicatif connecté), pas un état propre à un
    // écran — voir sa documentation dans injection_container.dart.
    return BlocProvider<AuthBloc>.value(
      value: sl<AuthBloc>(),
      child: MaterialApp(
        title: 'Cartodex',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const CardSetsPage(),
      ),
    );
  }
}