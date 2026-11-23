import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../l10n/l10n.dart';
import '../../card_sets/bloc/card_sets_bloc.dart';
import '../../sync/bloc/sync_bloc.dart';
import '../widgets/catalog_sync_tile.dart';
import '../widgets/cloud_account_section.dart';
import '../widgets/cloud_sync_feedback_listener.dart';
import '../widgets/cloud_sync_tile.dart';
import '../widgets/language_tile.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/tcgp_accounts_tile.dart';

/// Écran des paramètres, ouvert depuis l'accueil. Regroupe :
///
/// - les comptes TCG Pocket ([TcgpAccountsTile]) ;
/// - la synchronisation du référentiel ([CatalogSyncTile]) ;
/// - la synchronisation cloud ([CloudSyncTile]) et le compte cloud
///   ([CloudAccountSection] : connexion, changement de mot de passe,
///   déconnexion) ;
/// - la langue ([LanguageTile]).
///
/// N'a pas de Bloc propre : il réutilise ceux de l'accueil
/// ([CardSetsBloc], [SyncBloc]), transmis par [route], pour qu'une
/// synchronisation lancée ici mette l'accueil à jour, et les Blocs
/// globaux fournis à la racine (`AuthBloc`, `LanguageCubit`).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// Route vers l'écran, avec les Blocs de l'accueil lus dans
  /// [context] (celui de `CardSetsPage`).
  static Route<void> route(BuildContext context) {
    final cardSetsBloc = context.read<CardSetsBloc>();
    final syncBloc = context.read<SyncBloc>();
    return MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<CardSetsBloc>.value(value: cardSetsBloc),
          BlocProvider<SyncBloc>.value(value: syncBloc),
        ],
        child: const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.settingsTitle,
      body: CloudSyncFeedbackListener(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            SettingsSectionHeader(title: l10n.settingsSectionCollection),
            const TcgpAccountsTile(),
            SettingsSectionHeader(title: l10n.settingsSectionCatalog),
            const CatalogSyncTile(),
            SettingsSectionHeader(title: l10n.settingsSectionCloud),
            const CloudSyncTile(),
            const CloudAccountSection(),
            SettingsSectionHeader(title: l10n.languageTitle),
            const LanguageTile(),
          ],
        ),
      ),
    );
  }
}
