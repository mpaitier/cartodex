import 'package:flutter/material.dart';

import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_extras.dart';
import 'account_edit_button.dart';
import 'extra_counts_label.dart';
import 'primary_account_star_button.dart';
import 'top_extra_sets_preview.dart';

/// Une ligne de la liste de comptes : nom, puis à droite le bouton
/// crayon ([AccountEditButton]) et l'étoile du compte principal
/// ([PrimaryAccountStarButton]).
///
/// La marge de droite de la ligne est réduite : les deux boutons ont
/// déjà leur propre zone d'appui, qui suffit à décoller l'étoile du
/// bord de l'écran.
///
/// Pour un compte secondaire, [extras] affiche sous le nom les cartes
/// qu'il possède en plus du principal (losanges / étoiles), et à côté
/// du nom et de ces totaux, les logos des trois sets où il en a le
/// plus ([TopExtraSetsPreview]). [onTap] ouvre le détail par set. Le
/// compte principal n'a rien de tout cela.
///
/// Avec un filtre par extension actif, [focusedCounts] remplace les
/// totaux sous le nom par les cartes en plus des extensions filtrées.
/// Quand une seule extension est filtrée, [focusedSetExtras] fournit
/// en plus le cadre vert si elles complètent le principal.
class AccountListItem extends StatelessWidget {
  const AccountListItem({
    required this.account,
    required this.onCrownTap,
    required this.onEditTap,
    this.extras,
    this.focusedCounts,
    this.focusedSetExtras,
    this.onTap,
    super.key,
  });

  final Account account;
  final VoidCallback onCrownTap;
  final VoidCallback onEditTap;

  /// `null` pour le compte principal.
  final AccountExtras? extras;

  /// Cartes en plus cumulées sur les extensions du filtre, `null` sans
  /// filtre.
  final ExtraCounts? focusedCounts;

  /// Cartes en plus dans l'extension du filtre quand une seule est
  /// cochée, pour le cadre vert ; `null` sinon.
  final SetExtras? focusedSetExtras;

  /// `null` pour le compte principal : la ligne n'est alors pas
  /// cliquable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final extras = this.extras;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      title: Row(
        children: [
          Expanded(
            child: _NameAndTotals(
              name: account.name,
              extras: extras,
              focusedCounts: focusedCounts,
              focusedSetExtras: focusedSetExtras,
            ),
          ),
          if (extras != null) ...[
            const SizedBox(width: 8),
            TopExtraSetsPreview(sets: extras.bySet),
          ],
        ],
      ),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AccountEditButton(onPressed: onEditTap),
          PrimaryAccountStarButton(
            isPrimary: account.isPrimary,
            onPressed: onCrownTap,
          ),
        ],
      ),
    );
  }
}

/// Nom du compte, et pour un secondaire ses cartes en plus juste en
/// dessous : au total, ou dans les extensions du filtre si
/// [focusedCounts] est fourni.
class _NameAndTotals extends StatelessWidget {
  const _NameAndTotals({
    required this.name,
    required this.extras,
    required this.focusedCounts,
    required this.focusedSetExtras,
  });

  final String name;
  final AccountExtras? extras;
  final ExtraCounts? focusedCounts;
  final SetExtras? focusedSetExtras;

  @override
  Widget build(BuildContext context) {
    final extras = this.extras;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (extras != null) ...[
          const SizedBox(height: 4),
          // Réduits au besoin plutôt que de déborder : sur un petit
          // écran, les logos des sets et les deux boutons laissent peu
          // de largeur à cette colonne.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _countsLabel(extras),
          ),
        ],
      ],
    );
  }

  Widget _countsLabel(AccountExtras extras) {
    final counts = focusedCounts;
    if (counts == null) return ExtraCountsLabel(counts: extras.totals);
    final single = focusedSetExtras;
    return ExtraCountsLabel(
      counts: counts,
      completesBase: single?.completesBase ?? false,
      completesAlternative: single?.completesAlternative ?? false,
    );
  }
}
