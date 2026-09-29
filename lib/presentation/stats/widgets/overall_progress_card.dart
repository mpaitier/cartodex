import 'package:flutter/material.dart';

/// Carte de progression globale de la collection : cartes possédées
/// sur le total, tous sets confondus, avec une barre de progression
/// et le pourcentage.
class OverallProgressCard extends StatelessWidget {
  const OverallProgressCard({required this.owned, required this.total, super.key});

  final int owned;
  final int total;

  double get _ratio => total == 0 ? 0 : owned / total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (_ratio * 100).toStringAsFixed(1);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Collection complète', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: _ratio, minHeight: 10),
            ),
            const SizedBox(height: 8),
            Text('$owned / $total cartes ($percent %)'),
          ],
        ),
      ),
    );
  }
}