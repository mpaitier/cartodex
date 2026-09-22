import 'package:flutter/material.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../domain/entities/pokemon_card.dart';
import 'card_grid.dart';

/// Grille de cartes à 3 volets, navigables au swipe :
/// - à gauche, uniquement les cartes de rareté losange (◆ à ◆◆◆◆) ;
/// - au milieu (volet par défaut), toutes les cartes, sans filtre
///   de rareté supplémentaire ;
/// - à droite, uniquement les cartes de rareté non-losange (★, ♛,
///   ✷ — les "secrètes").
///
/// [cards] est déjà filtrée en amont (booster, puces de rareté —
/// voir [SetDetailState.visibleCards][../bloc/set_detail_state.dart]) :
/// le swipe ajoute un troisième niveau de filtrage purement local à
/// ce widget, sans passer par le Bloc. Les cartes sans rareté
/// connue (certaines promos) n'apparaissent que sur le volet du
/// milieu.
///
/// `StatefulWidget` uniquement pour garder le [PageController] en
/// vie d'un build à l'autre : recréé à chaque frame, il ramènerait
/// l'utilisateur au volet du milieu à chaque bascule de possession.
class CardGridPager extends StatefulWidget {
  const CardGridPager({
    required this.cards,
    required this.primaryOwnedCardIds,
    required this.secondaryOwnedCardIds,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  final List<PokemonCard> cards;
  final Set<String> primaryOwnedCardIds;
  final Set<String> secondaryOwnedCardIds;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onDoubleTap;

  @override
  State<CardGridPager> createState() => _CardGridPagerState();
}

class _CardGridPagerState extends State<CardGridPager> {
  final PageController _controller = PageController(initialPage: 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PokemonCard> get _diamondCards => widget.cards.where((card) {
        final rarity = CardRarity.fromCode(card.rarity);
        return rarity != null && rarity.group == RarityGroup.diamond;
      }).toList();

  List<PokemonCard> get _nonDiamondCards => widget.cards.where((card) {
        final rarity = CardRarity.fromCode(card.rarity);
        return rarity != null && rarity.group != RarityGroup.diamond;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        _grid(_diamondCards),
        _grid(widget.cards),
        _grid(_nonDiamondCards),
      ],
    );
  }

  Widget _grid(List<PokemonCard> cards) {
    return CardGrid(
      cards: cards,
      primaryOwnedCardIds: widget.primaryOwnedCardIds,
      secondaryOwnedCardIds: widget.secondaryOwnedCardIds,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
    );
  }
}