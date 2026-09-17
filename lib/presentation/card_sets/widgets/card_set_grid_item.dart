import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';

/// Une tuile de la grille de sets : logo, nom et nombre de cartes.
///
/// Composant purement visuel, sans connaissance du Bloc parent :
/// toute interaction remonte via [onTap].
class CardSetGridItem extends StatelessWidget {
  const CardSetGridItem({required this.set, required this.onTap, super.key});

  final CardSet set;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(child: _SetLogo(url: set.logoUrl)),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    '${set.totalCardCount} cartes',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo du set, avec repli sur une icône générique quand TCGdex
/// n'en fournit pas (sets promotionnels) ou que le chargement
/// échoue.
class _SetLogo extends StatelessWidget {
  const _SetLogo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) {
      return const ColoredBox(
        color: Colors.black12,
        child: Icon(Icons.style_outlined),
      );
    }
    return ColoredBox(
      color: Colors.black12,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (context, _) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, _, __) =>
            const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}