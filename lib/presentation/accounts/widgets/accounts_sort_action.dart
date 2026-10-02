import 'package:flutter/material.dart';

import '../bloc/accounts_sort_option.dart';

/// Action d'AppBar ouvrant le menu de tri de la liste des comptes.
///
/// Le critère courant est coché dans le menu. Composant purement
/// visuel : le choix remonte via [onSelected].
class AccountsSortAction extends StatelessWidget {
  const AccountsSortAction({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final AccountsSortOption selected;
  final ValueChanged<AccountsSortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AccountsSortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Trier les comptes',
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in AccountsSortOption.values)
          CheckedPopupMenuItem<AccountsSortOption>(
            value: option,
            checked: option == selected,
            child: Text(option.label),
          ),
      ],
    );
  }
}