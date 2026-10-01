import 'package:flutter/material.dart';

import '../../../domain/entities/collection_stats.dart';
import '../../../domain/entities/progress_count.dart';
import '../../set_detail/widgets/pack_avatar.dart';
import 'progress_count_label.dart';

/// Boosters à ouvrir en priorité, groupés par set — voir
/// `CollectionStats.priorityBoosterProgress` (sets pas encore
/// complets côté boosters, du moins avancé au plus avancé ; sets
/// promotionnels exclus).
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
/// principal, Y ce que les secondaires ont en plus, Z le total.
class PriorityBoostersList extends StatelessWidget {
  const PriorityBoostersList({required this.setProgress, super.key});

  final List<SetBoosterProgress> setProgress;

  @override
  Widget build(BuildContext context) {
    if (setProgress.isEmpty) {
      return const Text('Tous les boosters synchronisés sont complets 🎉');
    }
    return Column(
      children: [
        for (final set in setProgress) _SetBoosterBlock(set: set),
      ],
    );
  }
}

class _SetBoosterBlock extends StatelessWidget {
  const _SetBoosterBlock({required this.set});

  final SetBoosterProgress set;

  /// L'icône du booster unique d'un set à un seul booster (nommée
  /// d'après le set seul, sans nom de booster). `null`
  /// pour un set à plusieurs boosters : chacun a alors sa propre
  /// ligne (avec icône) dans [_BoosterBracket], l'icône de l'un
  /// d'eux ne représenterait pas le set.
  Widget? get _singleBoosterAvatar {
    if (set.hasMultipleBoosters || set.boosters.isEmpty) return null;
    return PackAvatar(setName: set.setName, radius: 10);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressRow(
            leading: _singleBoosterAvatar,
            label: set.setName,
            labelStyle: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            progress: set.progress,
          ),
          if (set.hasMultipleBoosters) _BoosterBracket(boosters: set.boosters),
        ],
      ),
    );
  }
}

/// Le trait vertical qui relie la progression globale d'un set à
/// celle de chacun de ses boosters, affichée en dessous.
class _BoosterBracket extends StatelessWidget {
  const _BoosterBracket({required this.boosters});

  final List<BoosterStats> boosters;

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
                    _BoosterRow(booster: booster),
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
  const _BoosterRow({required this.booster});

  final BoosterStats booster;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _ProgressRow(
        leading: PackAvatar(
          setName: booster.setName,
          packName: booster.packName,
          radius: 10,
        ),
        label: booster.packName,
        progress: booster.progress,
      ),
    );
  }
}

/// Une ligne "[icône] nom — X (+Y) / Z", réutilisée pour la ligne
/// d'un set et pour celle de chacun de ses boosters. [leading] est
/// facultatif : sans lui, la ligne commence directement par le nom.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.progress,
    this.leading,
    this.labelStyle,
  });

  final String label;
  final ProgressCount progress;
  final Widget? leading;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(label, style: labelStyle ?? theme.textTheme.bodySmall),
        ),
        ProgressCountLabel(progress: progress),
      ],
    );
  }
}