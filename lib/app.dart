import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/card_sets/view/card_sets_page.dart';
import 'presentation/rarity_scope/bloc/rarity_scope_cubit.dart';

class CartodexApp extends StatelessWidget {
  const CartodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc et RarityScopeCubit sont fournis ici, à la racine : ce
    // sont des états globaux de l'app (le compte applicatif connecté,
    // le périmètre de raretés Σ / losange / étoile), pas des états
    // propres à un écran — voir leur documentation dans
    // injection_container.dart.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
        BlocProvider<RarityScopeCubit>.value(value: sl<RarityScopeCubit>()),
      ],
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
