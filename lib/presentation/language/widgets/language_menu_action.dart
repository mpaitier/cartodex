import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_language.dart';
import '../../../l10n/l10n.dart';
import '../bloc/language_cubit.dart';
import 'app_language_label.dart';

/// Action d'AppBar de l'accueil pour changer la langue d'affichage :
/// langue du téléphone, français ou anglais. La langue active est
/// cochée.
///
/// Passe par [LanguageCubit], fourni à la racine : le changement
/// s'applique à toute l'app et il est mémorisé.
class LanguageMenuAction extends StatelessWidget {
  const LanguageMenuAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = context.watch<LanguageCubit>().state;
    return PopupMenuButton<AppLanguage>(
      icon: const Icon(Icons.translate),
      tooltip: l10n.languageMenuTooltip,
      initialValue: current,
      onSelected: (language) => context.read<LanguageCubit>().select(language),
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          CheckedPopupMenuItem<AppLanguage>(
            value: language,
            checked: language == current,
            child: Text(language.label(l10n)),
          ),
      ],
    );
  }
}
