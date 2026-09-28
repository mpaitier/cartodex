import 'package:flutter/material.dart';

/// Scaffold commun à tous les écrans, pour garder une structure
/// homogène (AppBar, zone sûre, actions) sans dupliquer ce code
/// dans chaque page.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.titleWidget,
    this.leadingActions,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  /// Toujours requis, même quand [titleWidget] est fourni : sert de
  /// repli tant que ce dernier n'est pas prêt (ex: pendant un
  /// chargement), et de valeur par défaut pour les écrans qui n'ont
  /// besoin que d'un titre simple.
  final String title;

  final Widget body;

  /// Remplace l'affichage par défaut de [title] quand fourni — pour
  /// un titre plus riche qu'un simple texte (voir
  /// `SetProgressSummary`).
  final Widget? titleWidget;

  /// Icônes affichées à gauche du titre, à la place du bouton retour
  /// automatique de `AppBar`. `null` (par défaut) laisse `AppBar`
  /// gérer son `leading` normalement (bouton retour sur un écran
  /// empilé par `Navigator`) : à ne fournir que sur un écran racine,
  /// sans navigation possible en arrière, comme `CardSetsPage`.
  final List<Widget>? leadingActions;

  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleWidget ?? Text(title),
        leading: leadingActions == null
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: leadingActions!),
        leadingWidth:
            leadingActions == null ? null : 48.0 * leadingActions!.length,
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}