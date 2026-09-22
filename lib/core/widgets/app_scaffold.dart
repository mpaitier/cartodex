import 'package:flutter/material.dart';

/// Scaffold commun à tous les écrans, pour garder une structure
/// homogène (AppBar, zone sûre, actions) sans dupliquer ce code
/// dans chaque page.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.titleWidget,
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

  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleWidget ?? Text(title),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}