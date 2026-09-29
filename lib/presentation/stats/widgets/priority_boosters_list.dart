import 'package:flutter/material.dart';

import '../../../domain/entities/collection_stats.dart';
import '../../set_detail/widgets/pack_avatar.dart';

/// Boosters à ouvrir en priorité, groupés par set — voir
/// `CollectionStats.priorityBoosterProgress` (sets pas encore
/// complets côté boosters, du moins avancé au plus avancé ; sets
/// promotionnels exclus).
///
/// Un set à un seul booster s'affiche comme une simple ligne : ce
/// booster unique EST le set du point de vue des boosters, pas la
/// peine de le répéter en dessous. Un set à plusieurs boosters
/// affiche sa progression globale (union des boosters, sans
/// double-comptage d'une carte partagée) puis le détail de chacun en
/// dessous, relié par un trait vertical.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressRow(
            label: set.setName,
            labelStyle: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            owned: set.owned,
            total: set.total,
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
      child: Row(
        children: [
          PackAvatar(packName: booster.packName, radius: 10),
          const SizedBox(width: 8),
          Expanded(
            child: _ProgressRow(
              label: booster.packName,
              owned: booster.owned,
              total: booster.total,
            ),
          ),
        ],
      ),
    );
  }
}

/// Une ligne "nom — X/Y (Z %)", réutilisée pour la ligne d'un set et
/// pour celle de chacun de ses boosters.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.owned,
    required this.total,
    this.labelStyle,
  });

  final String label;
  final int owned;
  final int total;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : owned / total;
    final percent = (ratio * 100).toStringAsFixed(0);
    return Row(
      children: [
        Expanded(
          child: Text(label, style: labelStyle ?? theme.textTheme.bodySmall),
        ),
        Text('$owned/$total ($percent %)', style: theme.textTheme.bodySmall),
      ],
    );
  }
}