import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Langues proposées par l'application.
///
/// L'ordre compte : quand la langue du téléphone n'est ni le français
/// ni l'anglais, Flutter retombe sur la première de la liste, l'anglais.
/// Les textes eux-mêmes sont dans `lib/l10n/arb/` (`app_fr.arb`,
/// `app_en.arb`).
const List<Locale> appSupportedLocales = [Locale('en'), Locale('fr')];

/// Accès court aux textes traduits depuis un widget :
/// `context.l10n.accountsTitle` plutôt que
/// `AppLocalizations.of(context).accountsTitle`.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
