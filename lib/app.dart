import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/app_language.dart';
import 'l10n/l10n.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/card_sets/view/card_sets_page.dart';
import 'presentation/language/bloc/language_cubit.dart';
import 'presentation/rarity_scope/bloc/rarity_scope_cubit.dart';

class CartodexApp extends StatelessWidget {
  const CartodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc, RarityScopeCubit et LanguageCubit sont fournis ici, à
    // la racine : ce sont des états globaux de l'app (le compte
    // applicatif connecté, le périmètre de raretés Σ / losange /
    // étoile, la langue d'affichage), pas des états propres à un
    // écran — voir leur documentation dans injection_container.dart.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
        BlocProvider<RarityScopeCubit>.value(value: sl<RarityScopeCubit>()),
        BlocProvider<LanguageCubit>.value(value: sl<LanguageCubit>()),
      ],
      child: BlocBuilder<LanguageCubit, AppLanguage>(
        builder: (context, language) {
          final languageCode = language.languageCode;
          return MaterialApp(
            onGenerateTitle: (context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            // `null` laisse Flutter suivre la langue du téléphone,
            // parmi appSupportedLocales.
            locale: languageCode == null ? null : Locale(languageCode),
            supportedLocales: appSupportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const CardSetsPage(),
          );
        },
      ),
    );
  }
}
