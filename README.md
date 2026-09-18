# Cartodex

Application mobile Flutter pour suivre sa collection de cartes Pokémon TCG Pocket.

## Contexte

Pokémon TCG Pocket n'expose aucune API publique permettant de récupérer la collection d'un compte joueur. Cartodex s'appuie donc sur deux sources de données distinctes :

- **[pokemon-tcg-pocket-database](https://github.com/flibustier/pokemon-tcg-pocket-database)** : référentiel de toutes les cartes existantes dans le jeu (nom, set, rareté, boosters), publié en JSON statique et servi via jsDelivr. Synchronisé via une action dans l'application.
- **Base locale (Drift)** : la possession de chaque carte, saisie manuellement par l'utilisateur et stockée uniquement sur l'appareil.

L'API [TCGdex](https://tcgdex.dev/fr/tcg-pocket) a été essayée en premier, mais elle ne modélise pas la répartition des cartes par booster à l'intérieur d'un set (une donnée centrale pour TCG Pocket, où chaque set se décline en plusieurs boosters). `pokemon-tcg-pocket-database` la fournit nativement, en plus d'être bien plus rapide à synchroniser : 3 fichiers JSON récupérés en une requête chacun, contre un appel par carte auparavant.

## Architecture

Clean Architecture en trois couches, avec MVVM côté présentation (chaque écran est piloté par un Bloc qui joue le rôle de ViewModel).

```
lib/
├── core/                 # Code transverse, sans dépendance métier
│   ├── constants/
│   ├── di/               # Injection de dépendances (get_it)
│   ├── error/            # Failures et Exceptions
│   ├── network/
│   ├── theme/
│   └── widgets/          # Composants UI génériques réutilisables
├── domain/                # Règles métier pures, aucune dépendance Flutter
│   ├── entities/           # CardCategory, CardSet, PokemonCard
│   ├── repositories/       # Interfaces abstraites (CardRepository)
│   └── usecases/           # Un fichier par action (SyncCardCatalog, GetCardSets...)
├── data/                   # Implémentation technique du domaine
│   ├── datasources/
│   │   ├── local/          # Base Drift (tables, DAO) : possession + cache du catalogue
│   │   └── remote/         # Client HTTP pokemon-tcg-pocket-database : catalogue uniquement
│   ├── models/              # DTO avec fromJson/toJson (CardModel, CardSetModel)
│   └── repositories/         # CardRepositoryImpl
└── presentation/
    ├── card_sets/             # Feature : liste des sets (écran d'accueil)
    │   ├── bloc/                # CardSetsBloc, événements, état
    │   ├── view/                 # CardSetsPage
    │   └── widgets/               # CardSetGrid, CardSetGridItem, CardSetsEmptyView, SyncCatalogAction
    └── set_detail/             # Feature : détail d'un set (cartes + possession)
        ├── bloc/                # SetDetailBloc, événements, état
        ├── view/                 # SetDetailPage
        └── widgets/               # CardGrid, CardGridItem, PackFilterBar
```

Règle de dépendance : `presentation` → `domain` ← `data`. Le domaine ne connaît jamais Flutter, Drift ou l'API ; il ne dépend que de ses propres interfaces.

Note de nommage : l'entité carte s'appelle `PokemonCard` (et non `Card`) pour éviter toute collision avec le widget Material `Card`. Pour la même raison, la ligne Drift générée pour la table `Cards` est explicitement nommée `CardRow` via `@DataClassName`.

## État actuel

Les fondations sont posées : structure du projet, thème, gestion d'erreurs, composants UI génériques.

La couche domaine du catalogue de cartes est posée : entités `CardCategory`, `CardSet`, `PokemonCard` (chacune avec un champ `packs`, la liste des boosters concernés) ; interface `CardRepository` ; use cases `SyncCardCatalog`, `GetCardSets`, `GetCardsBySet`, `GetOwnedCardIds`, `SetCardOwned`.

La couche data du catalogue de cartes est posée :
- **Remote** : `CardRemoteDataSource`, qui récupère `sets.json`, `cards.json` et `cards.extra.json` depuis `pokemon-tcg-pocket-database` (via jsDelivr) — la catégorie de chaque carte (Pokémon / Dresseur / Énergie) est croisée depuis `cards.extra.json`, seul fichier à la porter.
- **Local** : base Drift (`AppDatabase`) avec trois tables — `CardSets`, `Cards` (référentiel, avec une colonne `packs`) et `OwnedCards` (possession, volontairement séparée et jamais affectée par une resynchronisation) — exposées via `CardLocalDataSource`.
- **Repository** : `CardRepositoryImpl`, qui synchronise depuis le référentiel distant vers Drift (une seule requête pour l'ensemble des cartes, réparties par set localement), et qui ne lit/écrit plus qu'en local une fois la synchronisation faite.

La couche présentation de l'écran d'accueil est posée :
- `CardSetsBloc` distingue le chargement local (`CardSetsStarted`, à l'ouverture de l'écran) de la synchronisation distante (`CardSetsSyncRequested`, déclenchée par l'utilisateur) : ouvrir l'écran ne dépend jamais du réseau.
- `CardSetsPage` affiche selon l'état : chargement, erreur (avec nouvelle tentative), aucun set encore synchronisé (invitation à synchroniser), ou grille des sets. La grille reste affichée pendant une resynchronisation.
- Composants dédiés : `CardSetGrid`, `CardSetGridItem` (nom, nombre de cartes, nombre de boosters), `CardSetsEmptyView`, `SyncCatalogAction` (action d'AppBar avec indicateur de chargement).
- `injection_container.dart` enregistre les cinq use cases et `CardSetsBloc` (en factory, une instance par écran).
- `CardSetsPage` remplace `HomePage` comme écran d'accueil de `CartodexApp`.

**Limitation connue** : `pokemon-tcg-pocket-database` ne fournit aucune URL d'image (ni logo de set, ni illustration de carte — seulement un nom de fichier). `CardSet.logoUrl` reste donc toujours `null` pour l'instant, et la grille affiche une icône générique à la place du logo. Trouver/brancher une source d'images est un point ouvert, pas encore résolu.

**Changement de schéma local** : `Cards` et `CardSets` ont chacune une nouvelle colonne `packs`. Aucune migration Drift n'est en place à ce stade du projet (`schemaVersion` reste à 1) : après avoir appliqué ce changement, désinstaller l'app du téléphone/émulateur (ou vider ses données) avant de relancer `flutter run`, pour repartir d'une base vierge.

La couche présentation de l'écran de détail d'un set est posée :
- `SetDetailBloc` charge en parallèle les cartes du set (`GetCardsBySet`) et l'ensemble des cartes possédées (`GetOwnedCardIds`). La possession se bascule de façon optimiste au tap : l'état local change immédiatement, `SetCardOwned` persiste en arrière-plan, et un échec revient en arrière sans vider toute la grille.
- Le filtre par booster (`PackFilterChanged`) s'appuie directement sur `CardSet.packs`, connu dès l'ouverture de l'écran (passé depuis `CardSetsPage`, pas besoin d'attendre le chargement des cartes) ; il se masque de lui-même quand un set n'a qu'un seul booster.
- Composants dédiés : `CardGrid`, `CardGridItem` (nom, numéro, rareté, badge de possession), `PackFilterBar`.
- Un appui sur une tuile de `CardSetsPage` ouvre désormais `SetDetailPage` pour ce set.

Prochaine étape : source d'images pour les cartes et les logos de sets (voir la limitation connue plus haut) — c'est ce qui manque le plus visiblement à ce stade.

## Mise en route

Ce projet a été rédigé à la main, sans exécution locale de `flutter create` ni `flutter pub get` (l'environnement de génération n'a pas accès au SDK Flutter ni à pub.dev). Pour le lancer :

1. Créer un nouveau projet Flutter vierge : `flutter create cartodex`
2. Remplacer le `pubspec.yaml` généré par celui fourni ici, et copier le contenu de `lib/` par-dessus celui généré.
3. Copier `analysis_options.yaml` et `.gitignore` à la racine.
4. Installer les dépendances : `flutter pub get`
5. Générer le code Drift : `dart run build_runner build --delete-conflicting-outputs`
6. Lancer l'application : `flutter run`