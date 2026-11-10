import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../../l10n/l10n.dart';
import '../../card_sets/widgets/card_set_logo.dart';

/// Bandeau en haut de la liste des comptes quand un filtre par
/// extension est actif : rappelle les extensions choisies (logos des
/// [_maxLogos] premières, puis leur nom ou leur nombre) et permet de
/// retirer le filtre sans rouvrir le panneau ([onClear]).
class ActiveSetFilterBanner extends StatelessWidget {
  const ActiveSetFilterBanner({
    required this.sets,
    required this.onClear,
    super.key,
  });

  /// Extensions du filtre, au moins une.
  final List<CardSet> sets;
  final VoidCallback onClear;

  static const int _maxLogos = 3;

  String _text(AppLocalizations l10n) => sets.length == 1
      ? l10n.accountsSetFilterSingle(sets.single.name)
      : l10n.accountsSetFilterMultiple(sets.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final logos = sets.take(_maxLogos).toList();
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        child: Row(
          children: [
            for (var i = 0; i < logos.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              SizedBox(
                width: 40,
                height: 28,
                child: CardSetLogo(url: logos[i].logoUrl),
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _text(l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              onPressed: onClear,
              tooltip: l10n.accountsClearFilterTooltip,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
