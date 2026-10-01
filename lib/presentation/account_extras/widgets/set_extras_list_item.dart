import 'package:flutter/material.dart';

import '../../../domain/entities/account_extras.dart';
import '../../accounts/widgets/extra_counts_label.dart';
import '../../card_sets/widgets/card_set_logo.dart';

/// Une ligne de la liste des sets d'un compte secondaire : logo, nom
/// du set, et les cartes que ce compte y possède en plus du principal
/// (losanges / étoiles). Un appui ouvre le détail du set, restreint
/// aux cartes de ce compte.
class SetExtrasListItem extends StatelessWidget {
  const SetExtrasListItem({
    required this.setExtras,
    required this.onTap,
    super.key,
  });

  final SetExtras setExtras;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final set = setExtras.set;
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 40,
        child: CardSetLogo(url: set.logoUrl),
      ),
      title: Text(set.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: ExtraCountsLabel(counts: setExtras.counts),
      onTap: onTap,
    );
  }
}