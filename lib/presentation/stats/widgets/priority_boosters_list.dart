import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/collection_stats.dart';
import '../../../domain/entities/progress_count.dart';
import '../../set_detail/widgets/pack_avatar.dart';
import 'expected_new_cards_label.dart';
import 'progress_count_label.dart';

/// Boosters à ouvrir en priorité, groupés par set — voir
/// `CollectionStats.priorityBoosterProgressFor` (sets pas encore
/// complets côté boosters, du plus intéressant au moins intéressant à
/// ouvrir ; sets promotionnels exclus).
///
/// Un set à un seul booster s'affiche comme une simple ligne, avec
/// l'icône de ce booster : ce booster unique EST le set du point de
/// vue des boosters, pas la peine de le répéter en dessous. Un set à
/// plusieurs boosters affiche sa progression globale (union des
/// boosters, sans double-comptage d'une carte partagée) puis le
/// détail de chacun en dessous, avec son icône, relié par un trait
/// vertical.
///
/// Chaque progression se lit "X (+Y) / Z" : X pour le compte
/// principal, Y ce que les secondaires ont en plus, Z le total. Sous
/// le nom de chaque booster, le nombre moyen de cartes manquantes par
/// ouverture ([ExpectedNewCardsLabel]), quand les probabilités du set
/// sont connues.
///
/// Un appui sur la ligne d'un set ou sur celle de l'un de ses boosters
/// remonte le set via [onSetTap] : la page ouvre alors son détail.
class PriorityBoostersList extends StatelessWidget {
  const PriorityBoostersList({
    required this.setProgress,
    required this.onSetTap,
    this.emptyMessage = 'Tous les boosters synchronisés sont complets 🎉',
    super.key,
  });

  final List<SetBoosterProgress> setProgress;

  final ValueChanged<CardSet> onSetTap;

  /// Texte affiché quand [setProgress] est vide (tout est complet).
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (setProgress.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(emptyMessage),
      );
    }
    return Column(
      children: [
        for (final set in setProgress)
          _SetBoosterBlock(set: set, onTap: () => onSetTap(set.set)),
      ],
    );
  }
}

class _SetBoosterBlock extends StatelessWidget {
  const _SetBoosterBlock({required this.set, required this.onTap});

  final SetBoosterProgress set;

  /// Ouvre le détail du set, depuis sa ligne comme depuis celle de
  /// l'un de ses boosters.
  final VoidCallback onTap;

  /// L'icône du booster unique d'un set à un seul booster (nommée
  /// d'après le set seul, sans nom de booster). `null`
  /// pour un set à plusieurs boosters : chacun a alors sa propre
  /// ligne (avec icône) dans [_BoosterBracket], l'icône de l'un
  /// d'eux ne représenterait pas le set.
  Widget? get _singleBoosterAvatar {
    if (set.hasMultipleBoosters || set.boosters.isEmpty) return null;
    return PackAvatar(setName: set.setName, radius: 10);
  }

  /// L'espérance affichée sur la ligne du set : seulement pour un set
  /// à un seul booster, où elle est celle de ce booster. Pour un set à
  /// plusieurs boosters, chaque ligne de booster porte la sienne.
  double? get _singleBoosterExpectedNewCards =>
      set.hasMultipleBoosters ? null : set.expectedNewCards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TappableRow(
            onTap: onTap,
            child: _ProgressRow(
              leading: _singleBoosterAvatar,
              label: set.setName,
              labelStyle: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              progress: set.progress,
              expectedNewCards: _singleBoosterExpectedNewCards,
            ),
          ),
          if (set.hasMultipleBoosters)
            _BoosterBracket(boosters: set.boosters, onTap: onTap),
        ],
      ),
    );
  }
}

/// Le trait vertical qui relie la progression globale d'un set à
/// celle de chacun de ses boosters, affichée en dessous.
class _BoosterBracket extends StatelessWidget {
  const _BoosterBracket({required this.boosters, required this.onTap});

  final List<BoosterStats> boosters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 8),
            Container(
              width: 2,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  for (final booster in boosters)
                    _BoosterRow(booster: booster, onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoosterRow extends StatelessWidget {
  const _BoosterRow({required this.booster, required this.onTap});

  final BoosterStats booster;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TappableRow(
      onTap: onTap,
      child: _ProgressRow(
        leading: PackAvatar(
          setName: booster.setName,
          packName: booster.packName,
          radius: 10,
        ),
        label: booster.packName,
        progress: booster.progress,
        expectedNewCards: booster.expectedNewCards,
      ),
    );
  }
}

/// Rend une ligne de la liste cliquable, avec l'effet d'encre
/// habituel et une marge verticale qui agrandit la zone d'appui.
class _TappableRow extends StatelessWidget {
  const _TappableRow({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    );
  }
}

/// Une ligne "[icône] nom — X (+Y) / Z", réutilisée pour la ligne
/// d'un set et pour celle de chacun de ses boosters. [leading] est
/// facultatif : sans lui, la ligne commence directement par le nom.
/// [expectedNewCards], quand il est fourni, s'affiche sous le nom.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.progress,
    this.leading,
    this.labelStyle,
    this.expectedNewCards,
  });

  final String label;
  final ProgressCount progress;
  final Widget? leading;
  final TextStyle? labelStyle;
  final double? expectedNewCards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expected = expectedNewCards;
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: labelStyle ?? theme.textTheme.bodySmall),
              if (expected != null)
                ExpectedNewCardsLabel(expectedNewCards: expected),
            ],
          ),
        ),
        ProgressCountLabel(progress: progress),
      ],
    );
  }
}
