import 'package:flutter/material.dart';

/// Scaffold commun à tous les écrans, pour garder une structure
/// homogène (AppBar, zone sûre, actions) sans dupliquer ce code
/// dans chaque page.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
