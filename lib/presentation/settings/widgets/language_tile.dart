import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/l10n.dart';
import '../../language/bloc/language_cubit.dart';
import '../../language/widgets/app_language_label.dart';
import '../../language/widgets/language_picker_dialog.dart';

/// Ligne « Langue » : affiche la langue active et ouvre
/// [LanguagePickerDialog]. Passe par [LanguageCubit], fourni à la
/// racine : le changement s'applique tout de suite à toute l'app et il
/// est mémorisé.
class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = context.watch<LanguageCubit>().state;
    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.languageTitle),
      subtitle: Text(current.label(l10n)),
      onTap: () => _pickLanguage(context),
    );
  }

  /// Le Cubit est lu avant l'attente, pour ne pas toucher au `context`
  /// après la fermeture de la popup.
  Future<void> _pickLanguage(BuildContext context) async {
    final cubit = context.read<LanguageCubit>();
    final language = await LanguagePickerDialog.show(
      context,
      current: cubit.state,
    );
    if (language != null) await cubit.select(language);
  }
}
