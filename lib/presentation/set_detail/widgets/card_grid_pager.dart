import 'package:flutter/material.dart';

import '../../../core/constants/card_rarities.dart';
import '../../../domain/entities/pokemon_card.dart';
import 'card_grid.dart';
import 'page_dots_indicator.dart';

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
  int _currentPage = 1;

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
    return Column(
      children: [
        PageDotsIndicator(currentPage: _currentPage),
        Expanded(
          child: PageView(
            controller: _controller,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _grid('diamond', _diamondCards),
              _grid('all', widget.cards),
              _grid('non_diamond', _nonDiamondCards),
            ],
          ),
        ),
      ],
    );
  }

  /// [pageKey] donne à chaque volet une [PageStorageKey] distincte :
  /// sans elle, rien ne garantit formellement que Flutter associe le
  /// bon offset de défilement au bon volet d'un swipe à l'autre — la
  /// clé le fixe explicitement plutôt que de compter sur un
  /// comportement implicite.
  Widget _grid(String pageKey, List<PokemonCard> cards) {
    return CardGrid(
      key: PageStorageKey<String>(pageKey),
      cards: cards,
      primaryOwnedCardIds: widget.primaryOwnedCardIds,
      secondaryOwnedCardIds: widget.secondaryOwnedCardIds,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
    );
  }
}