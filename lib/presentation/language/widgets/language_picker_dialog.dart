import 'package:flutter/material.dart';

import '../../../domain/entities/app_language.dart';
import '../../../l10n/l10n.dart';
import 'app_language_label.dart';

/// Popup de choix de la langue : langue du téléphone, français ou
/// anglais. La langue active est cochée. Renvoie la langue choisie,
/// `null` si la popup est fermée sans choix.
class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({required this.current, super.key});

  final AppLanguage current;

  static Future<AppLanguage?> show(
    BuildContext context, {
    required AppLanguage current,
  }) {
    return showDialog<AppLanguage>(
      context: context,
      builder: (_) => LanguagePickerDialog(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SimpleDialog(
      title: Text(l10n.languageTitle),
      children: [
        for (final language in AppLanguage.values)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(language),
            child: Row(
              children: [
                Expanded(child: Text(language.label(l10n))),
                if (language == current) const Icon(Icons.check),
              ],
            ),
          ),
      ],
    );
  }
}
