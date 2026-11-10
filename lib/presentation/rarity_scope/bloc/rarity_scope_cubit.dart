import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/rarity_scope.dart';

/// ViewModel du périmètre de raretés (Σ / losange / étoile), commun à
/// toute l'application.
///
/// Un seul choix pour tous les écrans : le bandeau de série et les
/// tuiles de l'accueil, la feuille "Toutes les séries", les
/// statistiques, et le volet ouvert par défaut dans le détail d'un
/// set. Changer le périmètre à un endroit le change partout, y compris
/// sur les écrans encore ouverts en dessous dans la pile de
/// navigation.
///
/// Fourni une seule fois à la racine (voir `CartodexApp`), comme
/// `AuthBloc` : c'est un état de l'app, pas d'un écran. Les Blocs
/// d'écran ne le lisent jamais directement ; leurs vues le suivent
/// avec un `BlocBuilder` ou un `BlocListener` et transmettent la
/// valeur, pour que chaque Bloc reste testable seul.
///
/// Non persisté : l'app redémarre toujours sur Σ (toutes les raretés).
class RarityScopeCubit extends Cubit<RarityScope> {
  RarityScopeCubit() : super(RarityScope.all);

  /// Passe au périmètre suivant du cycle Σ → losange → étoile → Σ.
  /// Utilisé par les boutons de raretés (top bar des statistiques,
  /// bandeau de série de l'accueil).
  void cycle() => emit(state.next);

  /// Fixe directement le périmètre, par exemple depuis un swipe dans
  /// le détail d'un set. Sans effet si [scope] est déjà le périmètre
  /// courant.
  void select(RarityScope scope) {
    if (scope == state) return;
    emit(scope);
  }
}
