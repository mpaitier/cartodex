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
│   ├── entities/           # CardCategory, CardSet, PokemonCard, Account
│   ├── repositories/       # Interfaces abstraites (CardRepository, AccountRepository)
│   └── usecases/           # Un fichier par action (SyncCardCatalog, GetCardSets, GetAccounts...)
├── data/                   # Implémentation technique du domaine
│   ├── datasources/
│   │   ├── local/          # Base Drift (tables, DAO) : catalogue, possession, comptes
│   │   └── remote/         # Client HTTP pokemon-tcg-pocket-database : catalogue uniquement
│   ├── models/              # DTO avec fromJson/toJson (CardModel, CardSetModel, AccountModel)
│   └── repositories/         # CardRepositoryImpl, AccountRepositoryImpl
└── presentation/
    ├── card_sets/             # Feature : liste des sets (écran d'accueil)
    │   ├── bloc/                # CardSetsBloc, événements, état
    │   ├── view/                 # CardSetsPage
    │   └── widgets/               # CardSetGrid, CardSetGridItem, CardSetsEmptyView, SyncCatalogAction
    ├── set_detail/             # Feature : détail d'un set (cartes + possession)
    │   ├── bloc/                # SetDetailBloc, événements, état
    │   ├── view/                 # SetDetailPage
    │   └── widgets/               # CardGrid, CardGridItem, PackFilterBar, PackAvatar
    └── accounts/               # Feature : gestion des comptes suivis
        ├── bloc/                 # AccountsBloc, événements, état
        ├── view/                  # AccountsPage
        └── widgets/                # AccountListItem, AddAccountDialog
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

**Changement de schéma local** : `Cards` et `CardSets` ont chacune une nouvelle colonne `packs`, `Accounts` est une nouvelle table, et `OwnedCards` passe d'une clé simple (`cardId`) à une clé composite (`cardId`, `accountId`) — la possession est désormais par compte. Aucune migration Drift n'est en place à ce stade du projet (`schemaVersion` reste à 1) : après avoir appliqué ces changements, désinstaller l'app du téléphone/émulateur (ou vider ses données) avant de relancer `flutter run`, pour repartir d'une base vierge.

La couche présentation de l'écran de détail d'un set est posée :
- `SetDetailBloc` charge les cartes du set (`GetCardsBySet`), tous les comptes (`GetAccounts`) et, pour chacun, les cartes qu'il possède (`GetOwnedCardIds`). Le tap simple bascule toujours la possession pour le compte principal (violet profond) ; le double-tap ouvre `SecondaryAccountPickerDialog` pour choisir un compte secondaire précis (bleu, icône flèche vers le haut). Les deux passent par le même use case (`SetCardOwned`) et la même mise à jour optimiste factorisée dans le Bloc : l'état local change immédiatement, un échec revient en arrière sans vider toute la grille. Sans compte encore créé, le tap simple affiche un message invitant à en créer un ; sans compte secondaire, le popup de double-tap fait de même.
- Le filtre par booster (`PackFilterChanged`) s'appuie directement sur `CardSet.packs`, connu dès l'ouverture de l'écran (passé depuis `CardSetsPage`, pas besoin d'attendre le chargement des cartes) ; il se masque de lui-même quand un set n'a qu'un seul booster.
- Composants dédiés : `CardGrid`, `CardGridPager` (3 volets swipeables — losange à gauche, tout au milieu, non-losange à droite — filtrage purement local, sans passer par le Bloc ; `PageDotsIndicator` — losange/rond/étoile plutôt que des points génériques — au-dessus, et une `PageStorageKey` par volet pour que chacun garde son propre défilement d'un swipe à l'autre), `CardGridItem` (nom, numéro au format `#XXX`, rareté affichée avec les symboles du jeu, badge de possession à deux états), `PackFilterBar` (avec icône de booster via `PackAvatar`), `RarityFilterBar` (multi-sélection, "Tout"), `SecondaryAccountPickerDialog`, `SetProgressSummary` (titre de l'AppBar : ◆/★/Σ possédé-sur-total, en vert quand complet — inspiré de l'écran de progression de l'app officielle TCG Pocket, condensé pour une AppBar ; un tap bascule le contour des boîtes entre violet — compte principal seul — et bleu — principal + cartes possédées par au moins un secondaire, en évitant tout double-comptage). `AppScaffold` accepte désormais un `titleWidget` optionnel pour ce genre de titre enrichi.
- `CardRarity` (`core/constants/card_rarities.dart`) convertit les codes bruts de la source (`C`, `SR`, `UR`...) vers la représentation du jeu : 1 à 4 losanges, 1 à 3 étoiles, 1 couronne, 1 à 2 étoiles chromatiques (table tirée de `rarities.json` de la source). `SR` et `SAR` partagent le même rendu (★★) — indissociables visuellement dans le jeu, seule la bordure (non reproduite ici) les distingue.
- Un appui sur une tuile de `CardSetsPage` ouvre désormais `SetDetailPage` pour ce set, dont le titre affiche "`<nom> - X acquis / total`" une fois les cartes chargées (compte principal).

La gestion de comptes est posée — première brique d'une future collection multi-comptes :
- Entité `Account` (`id` local, `name` affiché, `gameAccountId` stocké mais jamais affiché ailleurs dans l'app, `isPrimary`) ; interface `AccountRepository` ; use cases `GetAccounts`, `AddAccount`, `SetPrimaryAccount`.
- Table Drift `Accounts` : le premier compte créé devient principal automatiquement, une seule opération transactionnelle échange ensuite le rôle entre deux comptes (jamais deux principaux à la fois, jamais aucun dès qu'il en existe un).
- `AccountsBloc`, `AccountsPage` (liste + FAB d'ajout), `AccountListItem` (étoile pleine jaune pour le principal, en contour gris et cliquable pour les autres), `AddAccountDialog` (formulaire nom + identifiant).
- Accessible depuis une action dédiée dans l'AppBar de `CardSetsPage`.

Les cinq étapes de la feuille de route initiale sont posées, ainsi que le titre enrichi de l'AppBar (`SetProgressSummary`, avec bascule principal/tous-comptes au tap). Reste explicitement en attente : une adaptation dynamique des puces de `RarityFilterBar` selon le volet actif de `CardGridPager`.

Passe de finition sur `set_detail` : titre et compteurs de `SetProgressSummary` centrés ; `PageDotsIndicator` déplacé en overlay bas (plutôt qu'au-dessus du filtre de rareté), et simplifié en 3 losanges plutôt que losange/rond/étoile ; puces de `RarityFilterBar` sans coche de sélection ni padding excessif ; `CardGridItem` affiche le numéro de la carte en grand à la place de l'image (sans `#`), l'icône générique n'apportait rien de plus qu'un numéro lisible ; les sets se lisent désormais du plus récent au plus ancien.

**Images (pocketcards.net)** : `pokemon-tcg-pocket-database` ne fournissant aucune URL exploitable (ni logo de set, ni illustration de carte, ni icône de booster), les trois sont désormais reconstruites à partir des noms du référentiel via `PocketCardsImageSlug`, sur le modèle non-officiel de [pocketcards.net](https://pocketcards.net). `CardGridItem` affiche de nouveau l'illustration de la carte (centrée, `BoxFit.contain`, sans recadrage) en plus du numéro en texte (`#XXX`, à côté de la rareté) ; `CardSetGridItem` affiche le logo du set ; `PackFilterBar` affiche l'icône de chaque booster via le nouveau composant `PackAvatar`. La conversion nom → slug reste déduite d'exemples observés, pas d'une spécification garantie : `PocketCardsImageSlug` porte une table de correctifs manuels (`_cardSlugOverrides`) pour les quelques cartes dont le nom brut du référentiel distant contient une erreur de saisie (espace manquant, etc.), repérées au fil des échecs de chargement loggés par `AppLogger`.

## Mise en route

Ce projet a été rédigé à la main, sans exécution locale de `flutter create` ni `flutter pub get` (l'environnement de génération n'a pas accès au SDK Flutter ni à pub.dev). Pour le lancer :

1. Créer un nouveau projet Flutter vierge : `flutter create cartodex`
2. Remplacer le `pubspec.yaml` généré par celui fourni ici, et copier le contenu de `lib/` par-dessus celui généré.
3. Copier `analysis_options.yaml` et `.gitignore` à la racine.
4. Installer les dépendances : `flutter pub get`
5. Générer le code Drift : `dart run build_runner build --delete-conflicting-outputs`
6. Lancer l'application : `flutter run`