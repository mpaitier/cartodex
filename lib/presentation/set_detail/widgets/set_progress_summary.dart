import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Résumé de progression affiché dans la barre de titre de
/// [SetDetailPage][../view/set_detail_page.dart] : distingue la
/// collection de base (cartes losange) des cartes alternatives
/// (étoile, couronne, chromatique), plus un total. Inspiré de
/// l'écran de progression de l'application officielle TCG Pocket,
/// condensé pour tenir dans la hauteur d'une AppBar plutôt que dans
/// une carte dépliable.
///
/// Un tap bascule entre compte principal uniquement (contour
/// violet) et principal + secondaires (contour bleu) — mêmes
/// couleurs que le badge de possession des cartes, pour rester
/// cohérent avec ce que chacune signifie déjà ailleurs dans l'app.
class SetProgressSummary extends StatefulWidget {
  const SetProgressSummary({
    required this.setName,
    required this.baseOwnedPrimary,
    required this.baseOwnedAllAccounts,
    required this.baseTotal,
    required this.alternativeOwnedPrimary,
    required this.alternativeOwnedAllAccounts,
    required this.alternativeTotal,
    super.key,
  });

  final String setName;

  final int baseOwnedPrimary;

  /// Cartes losange possédées par le principal ou par au moins un
  /// secondaire (union, sans double-comptage — voir
  /// `SetDetailState.baseOwnedAllAccounts`).
  final int baseOwnedAllAccounts;

  final int baseTotal;

  final int alternativeOwnedPrimary;
  final int alternativeOwnedAllAccounts;
  final int alternativeTotal;

  @override
  State<SetProgressSummary> createState() => _SetProgressSummaryState();
}

class _SetProgressSummaryState extends State<SetProgressSummary> {
  /// État purement local à l'affichage : ne vaut pas la peine de
  /// vivre dans le Bloc, et doit de toute façon persister d'un
  /// rebuild à l'autre (StatefulWidget), pas être réinitialisé à
  /// chaque tap sur une carte.
  bool _includeSecondary = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _includeSecondary
        ? AppColors.ownedBySecondaryAccount
        : AppColors.ownedByPrimaryAccount;
    final baseOwned = _includeSecondary
        ? widget.baseOwnedAllAccounts
        : widget.baseOwnedPrimary;
    final alternativeOwned = _includeSecondary
        ? widget.alternativeOwnedAllAccounts
        : widget.alternativeOwnedPrimary;

    return InkWell(
      onTap: () => setState(() => _includeSecondary = !_includeSecondary),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.setName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RarityGroupCount(
                  symbol: '◆',
                  owned: baseOwned,
                  total: widget.baseTotal,
                  borderColor: borderColor,
                ),
                const SizedBox(width: 6),
                _RarityGroupCount(
                  symbol: '★',
                  owned: alternativeOwned,
                  total: widget.alternativeTotal,
                  borderColor: borderColor,
                ),
                const SizedBox(width: 6),
                _RarityGroupCount(
                  symbol: 'Σ',
                  owned: baseOwned + alternativeOwned,
                  total: widget.baseTotal + widget.alternativeTotal,
                  borderColor: borderColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Une petite boîte "symbole owned/total", au contour coloré selon
/// le mode courant (violet/bleu) et au texte en vert quand complet
/// — comme le "72/72" bleu de l'app officielle.
class _RarityGroupCount extends StatelessWidget {
  const _RarityGroupCount({
    required this.symbol,
    required this.owned,
    required this.total,
    required this.borderColor,
  });

  final String symbol;
  final int owned;
  final int total;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final complete = total > 0 && owned >= total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$symbol $owned/$total',
        style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 12,
              fontWeight: complete ? FontWeight.bold : FontWeight.normal,
              color: complete ? AppColors.complete : null,
            ),
      ),
    );
  }
}