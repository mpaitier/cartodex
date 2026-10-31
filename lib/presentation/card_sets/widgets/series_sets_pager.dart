import 'package:flutter/material.dart';

import '../../../domain/entities/card_set.dart';
import '../../../domain/entities/set_progress.dart';
import '../bloc/series_tab.dart';
import 'card_set_grid.dart';

/// Grilles de sets, une page par série, navigables au swipe : vers
/// la gauche pour les séries plus anciennes, "Promo" en dernière
/// page. Même principe que `CardGridPager` dans le détail d'un set.
///
/// La série affichée reste pilotée par le Bloc, dans les deux sens :
/// - un swipe remonte la nouvelle série via [onSeriesChanged] ;
/// - un changement de [selectedKey] venu d'ailleurs (barre du bas,
///   feuille "Toutes les séries", nouvelle série après une
///   synchronisation) déplace le pager sur la bonne page.
///
/// `StatefulWidget` uniquement pour garder le [PageController] en
/// vie d'un build à l'autre.
class SeriesSetsPager extends StatefulWidget {
  const SeriesSetsPager({
    required this.tabs,
    required this.selectedKey,
    required this.setsForSeries,
    required this.onSetTap,
    required this.onSeriesChanged,
    this.progressBySetId = const {},
    super.key,
  });

  /// Toutes les séries, dans l'ordre des pages
  /// (`CardSetsState.seriesTabs`).
  final List<SeriesTab> tabs;
  final String? selectedKey;

  /// Les sets d'une série (`CardSetsState.setsForSeries`).
  final List<CardSet> Function(String seriesKey) setsForSeries;

  final ValueChanged<CardSet> onSetTap;
  final ValueChanged<String> onSeriesChanged;
  final Map<String, SetProgress> progressBySetId;

  @override
  State<SeriesSetsPager> createState() => _SeriesSetsPagerState();
}

class _SeriesSetsPagerState extends State<SeriesSetsPager> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _selectedIndex {
    final index = widget.tabs.indexWhere((tab) => tab.key == widget.selectedKey);
    return index < 0 ? 0 : index;
  }

  @override
  void didUpdateWidget(covariant SeriesSetsPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Après la frame : déplacer le pager pendant le build déclencherait
    // onPageChanged (donc un événement Bloc) au milieu de ce build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPageWithSelection());
  }

  /// Aligne la page affichée sur [SeriesSetsPager.selectedKey]. Une
  /// série voisine est atteinte par une animation ; une série plus
  /// lointaine par un saut direct, pour ne pas faire défiler toutes
  /// les pages intermédiaires (et ne pas déclencher un
  /// [SeriesSetsPager.onSeriesChanged] pour chacune d'elles).
  void _syncPageWithSelection() {
    if (!mounted || !_controller.hasClients) return;
    final target = _selectedIndex;
    final current = _controller.page?.round() ?? target;
    if (current == target) return;
    if ((target - current).abs() == 1) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpToPage(target);
    }
  }

  void _onPageChanged(int page) {
    final key = widget.tabs[page].key;
    // Une page atteinte par _syncPageWithSelection est déjà la série
    // sélectionnée : inutile de la renvoyer au Bloc.
    if (key != widget.selectedKey) widget.onSeriesChanged(key);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.tabs.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final tab = widget.tabs[index];
        return CardSetGrid(
          // Une clé par série : chaque page garde sa propre position
          // de défilement d'un swipe à l'autre.
          key: PageStorageKey<String>('series_${tab.key}'),
          sets: widget.setsForSeries(tab.key),
          progressBySetId: widget.progressBySetId,
          onSetTap: widget.onSetTap,
        );
      },
    );
  }
}