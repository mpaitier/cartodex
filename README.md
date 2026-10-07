# Cartodex

Application mobile Flutter pour suivre sa collection de cartes Pokémon TCG Pocket, sur un ou plusieurs comptes de jeu, avec synchronisation optionnelle entre appareils.

## Contexte

Pokémon TCG Pocket n'expose aucune API publique qui permette de récupérer la collection d'un joueur. Cartodex combine donc trois sources, chacune avec un rôle précis :

- **Catalogue des cartes** : [pokemon-tcg-pocket-database](https://github.com/flibustier/pokemon-tcg-pocket-database), trois fichiers JSON statiques servis par jsDelivr (`sets.json`, `cards.json`, `cards.extra.json`). Il est téléchargé à la demande, puis stocké en local.
- **Possession des cartes** : saisie à la main par l'utilisateur, stockée uniquement dans une base SQLite locale (Drift). Elle ne dépend jamais du catalogue : une resynchronisation complète du référentiel n'y touche pas.
- **Compte applicatif** (facultatif) : Firebase Auth et Firestore, pour retrouver ses comptes et sa possession sur un autre appareil.

L'application fonctionne entièrement hors ligne une fois le catalogue téléchargé, et sans compte applicatif.

TCGdex avait été essayé en premier. Son modèle ne décrit pas la répartition des cartes par booster à l'intérieur d'un set, alors que chaque set de TCG Pocket se décline en plusieurs boosters au contenu différent. `pokemon-tcg-pocket-database` fournit cette information, et la synchronisation passe de une requête par carte à trois requêtes au total.

## Fonctionnalités

**Catalogue et sets**
- Synchronisation manuelle du référentiel depuis l'AppBar, avec indicateur de chargement. L'ouverture de l'écran ne dépend jamais du réseau.
- Grille des sets, du plus récent au plus ancien, avec filtre par série (A, B, …) et un onglet « Promo » qui regroupe les sets promotionnels.
- Chaque tuile affiche le logo du set, son nombre de cartes et de boosters, et une bordure de progression coupée en deux : la moitié gauche suit les cartes losange (◆), la moitié droite les cartes alternatives (★). Les pourcentages sont écrits sous la tuile.

**Détail d'un set**
- Trois volets au swipe : cartes losange à gauche, toutes les cartes au milieu, cartes alternatives à droite.
- Filtre par booster, et filtre de rareté en multi-sélection dont les puces s'adaptent au volet actif.
- Filtre de possession : tout, compte principal, comptes secondaires, cartes manquantes. Quand « secondaires » est choisi et que plusieurs comptes ont des cartes dans le set, un sous-filtre permet de cibler un compte.
- Pincement à deux doigts : rapprocher les doigts passe la grille de 3 à 5 colonnes (illustration et badge seuls, sans nom ni rareté), les écarter revient à 3.
- Tap simple : bascule la possession pour le compte principal. Double-tap : ouvre un choix de compte secondaire.
- Bouton « + » : marque d'un coup, après confirmation, les cartes affichées à l'écran pour le compte principal.
- Titre de l'AppBar avec les compteurs ◆ / ★ / Σ. Un tap bascule entre « compte principal seul » et « principal + secondaires ».

**Comptes**
- Plusieurs comptes de jeu suivis dans la même application, dont un seul est principal (étoile pleine). Les autres sont secondaires et le principal peut être changé en un tap.
- Tri de la liste (ordre de création, alphabétique, cartes en plus), le principal restant toujours en tête.
- Pour chaque secondaire, un écran liste les sets où il possède des cartes que le principal n'a pas. Un tap sur un set ouvre son détail restreint à ces cartes.

**Statistiques**
- Progression globale, par série, et boosters à ouvrir en priorité (du moins avancé au plus avancé).
- Chaque progression se lit « X (+Y) / Z » : X pour le compte principal, Y pour ce que les secondaires ajoutent, Z pour le total.
- Un bouton cycle entre trois périmètres de raretés : toutes, losange, étoile.

**Synchronisation cloud**
- Connexion par email et mot de passe, ou par Google.
- Fusion des comptes et de la possession avec Firestore, avec un bilan affiché à la fin (« 2 compte(s) récupéré(s), 14 carte(s) envoyée(s) »).

## Stack technique

| Domaine | Choix |
|---|---|
| Framework | Flutter (Dart 3.13+, voir `pubspec.lock`), Material 3, thème clair et sombre |
| État | `flutter_bloc` (Bloc), `equatable` |
| Injection de dépendances | `get_it` |
| Gestion des erreurs | `dartz` (`Either<Failure, T>`) |
| Persistance locale | `drift` + `sqlite3_flutter_libs` |
| Réseau | `http`, `connectivity_plus` |
| Compte et cloud | `firebase_core`, `firebase_auth`, `google_sign_in` (v7), `cloud_firestore` |
| Images | `cached_network_image` |
| Identifiants | `uuid` |
| Qualité | `flutter_lints`, `strict-casts` et `strict-inference` activés dans `analysis_options.yaml` |

## Architecture

Clean Architecture en trois couches, avec MVVM côté présentation : chaque écran est piloté par un Bloc qui joue le rôle de ViewModel, et les widgets ne contiennent aucune logique métier.

```
presentation  ──►  domain  ◄──  data
 (Bloc, vues,      (entités,     (datasources,
  widgets)         use cases,     modèles,
                   interfaces     implémentations
                   de repository) de repository)
```

Le domaine ne dépend ni de Flutter, ni de Drift, ni de Firebase. Il ne connaît que ses propres interfaces. La couche data est la seule à savoir que le catalogue vient de jsDelivr ou que le cloud est Firestore.

Le trajet d'une action, par exemple le tap sur une carte :

```
CardGridItem (onTap)
  → SetDetailBloc (événement CardOwnershipToggled)
    → SetCardOwned (use case)
      → CardRepository (interface du domaine)
        → CardRepositoryImpl
          → CardLocalDataSource → Drift
```

Quelques règles appliquées partout :

- **Erreurs.** Les datasources lèvent des exceptions (`ServerException`, `CacheException`). Les repositories les convertissent en `Failure`, renvoyées sous forme de `Either` : aucune exception technique ne remonte au domaine ni à l'interface.
- **Use cases.** Un fichier par action, avec un contrat commun (`UseCase<Type, Params>`). Les calculs de complétion (`GetCollectionStats`, `GetSetsProgress`, `GetSecondaryAccountsExtras`) sont des use cases et non des méthodes de repository, car ce sont des règles métier. `WatchAuthState` fait exception : c'est un flux continu, donc il n'utilise pas le contrat basé sur `Future`.
- **Injection.** Services, datasources, repositories et use cases sont des singletons paresseux. Les Blocs sont enregistrés en factory, une instance par écran, sauf `AuthBloc` : il n'y a qu'un seul état de connexion pour toute l'application, fourni une fois à la racine.
- **Mises à jour optimistes.** La bascule de possession change l'état immédiatement, puis revient en arrière avec un message si l'écriture locale échoue. L'ajout en masse est tout ou rien.
- **Composants.** Chaque écran est découpé en petits widgets sans connaissance du Bloc parent : ils reçoivent leurs données et remontent les interactions par callbacks.

## Structure du projet

```
lib/
├── main.dart                  # Initialisation Firebase et injection, puis runApp
├── app.dart                   # MaterialApp, thèmes, AuthBloc fourni à la racine
├── core/
│   ├── constants/             # AppConstants (URLs, nom de la base), CardRarity
│   ├── di/                    # injection_container.dart (get_it)
│   ├── error/                 # Exceptions et Failures
│   ├── network/               # NetworkInfo (abstraction de la connectivité)
│   ├── theme/                 # AppColors, AppTheme
│   ├── utils/                 # AppLogger, PocketCardsImageSlug
│   └── widgets/               # AppScaffold, AppLoadingIndicator, AppErrorView
├── domain/
│   ├── entities/              # PokemonCard, CardSet, Account, AccountExtras, CollectionStats,
│   │                          # ProgressCount, SetProgress, RarityScope, AppUser, CloudAccount, SyncResult
│   ├── repositories/          # CardRepository, AccountRepository, AuthRepository, CloudSyncRepository
│   └── usecases/              # Un fichier par action (catalogue, comptes, statistiques, auth, synchro)
├── data/
│   ├── datasources/
│   │   ├── local/             # AppDatabase (Drift), tables, datasources cartes et comptes
│   │   └── remote/            # Client HTTP du catalogue
│   ├── models/                # CardModel, CardSetModel, AccountModel, AppUserModel, CloudAccountModel
│   └── repositories/          # Implémentations des quatre repositories
└── presentation/
    ├── card_sets/             # Accueil : liste des sets, filtre par série, synchronisations
    ├── set_detail/            # Détail d'un set : cartes, filtres, possession
    ├── accounts/              # Gestion des comptes de jeu
    ├── account_extras/        # Cartes qu'un secondaire possède en plus du principal
    ├── stats/                 # Statistiques de complétion
    ├── auth/                  # Connexion au compte applicatif
    └── sync/                  # Synchronisation cloud
```

Chaque feature de `presentation/` suit le même découpage : `bloc/` (événements, état, Bloc), `view/` (la page) et `widgets/` (les composants).

## Modèle de données

### Base locale (Drift, schéma v2)

| Table | Rôle |
|---|---|
| `card_sets` | Sets du référentiel : id, nom, nombre de cartes, série, logo, boosters |
| `cards` | Cartes du référentiel : id (`A1-001`), nom, catégorie, set, image, rareté, boosters |
| `owned_cards` | Possession, clé composite (`card_id`, `account_id`) |
| `accounts` | Comptes de jeu suivis : id (UUID), nom, identifiant de jeu, principal ou non, date de création |

Les listes (boosters, types) sont stockées en une chaîne séparée par des virgules : une carte n'a jamais que quelques valeurs, une table relationnelle serait disproportionnée.

**Migration v1 → v2.** Les identifiants de compte passent d'entiers auto-incrémentés à des UUID, pour qu'un compte créé hors ligne sur deux appareils ne puisse pas entrer en collision au moment de la synchronisation. SQLite ne sait pas changer le type d'une colonne en place : les deux tables concernées sont renommées, recréées au schéma courant, remplies par copie (l'id `1` devient `"1"`) puis supprimées, dans une transaction. Les anciens comptes sont remplacés par de vrais UUID au premier passage dans `SyncWithCloud`.

### Firestore

Un document par compte de jeu, avec les cartes possédées dans un champ tableau : une synchronisation coûte une lecture par compte, pas une par carte.

```
users/{userId}/accounts/{accountId}
  name: string
  gameAccountId: string
  isPrimary: bool
  createdAt: timestamp
  ownedCardIds: string[]
```

Règles de sécurité à déployer côté console :

```
match /users/{userId}/accounts/{accountId} {
  allow read, write: if request.auth != null
    && request.auth.uid == userId;
}
```

## Règles métier

**Possession.** Elle est propre à chaque compte. Le tap simple agit sur le compte principal, le double-tap sur un secondaire choisi dans une liste. Il y a toujours exactement un compte principal dès qu'au moins un compte existe, et le premier compte créé le devient automatiquement.

**Losange et alternatif.** Une carte est « de base » si sa rareté est de groupe losange. Tout le reste (étoile, couronne, chromatique, et cartes sans rareté connue comme certaines promos) est « alternatif ». Toute l'application passe par `CardRarity.isBase`, pour que les écrans affichent les mêmes chiffres.

**Progression « X (+Y) / Z ».** Y compte les cartes possédées par au moins un secondaire et pas par le principal, sans doublon même si plusieurs secondaires la possèdent. X + Y ne dépasse donc jamais Z. La barre ou la bordure passe au vert seulement quand le principal possède, à lui seul, tout le groupe.

**Boosters prioritaires.** La progression d'un set côté boosters est l'union de ses boosters, pas la somme : une carte présente dans plusieurs boosters ne compte qu'une fois. Les sets promotionnels et les sets sans booster connu sont exclus. Le tri ne regarde que le compte principal, puisque les cartes des secondaires ne rendent pas un booster moins utile pour lui.

**Synchronisation du catalogue.** Le total de cartes d'un set est recalculé à partir des cartes réellement récupérées, car la source l'omet pour certains sets (« Promo B ») ou peut diverger.

**Synchronisation cloud.** La règle de fusion est que « possédée » l'emporte toujours : une carte marquée possédée d'un côté l'est des deux après synchronisation, et aucune carte n'est jamais démarquée. L'envoi utilise `arrayUnion` côté Firestore, pour que la règle tienne même côté serveur. Déroulé de `SyncWithCloud` :

1. Remplacement des identifiants hérités (simples nombres) par des UUID.
2. Comparaison compte par compte : envoi de ce qui manque au cloud, récupération de ce qui manque en local.
3. Import des comptes qui n'existent que dans le cloud.

Le traitement s'arrête à la première erreur sans revenir en arrière. La fusion étant idempotente, une nouvelle synchronisation rattrape le reste.

**Images.** La source ne fournit aucune URL exploitable. Les illustrations de cartes, logos de sets et icônes de boosters sont reconstruits à partir des noms du référentiel via `PocketCardsImageSlug`, sur le modèle de [pocketcards.net](https://pocketcards.net). Le site n'a pas d'API documentée : la conversion est déduite d'exemples observés. Elle gère les noms collés (« Teal MaskOgerpon »), les préfixes de forme régionale (« Galarianzigzagoon »), les chiffres en fin de nom (« Porygon2 ») et dispose d'une table de correctifs manuels. En debug, `AppLogger` signale chaque image introuvable.

## Installation

Prérequis : un SDK Flutter compatible avec `pubspec.lock` (Dart 3.13 et Flutter 3.47 au minimum) et un projet Firebase.

1. Récupérer les dépendances :
   ```
   flutter pub get
   ```
2. Générer le code Drift (les fichiers `*.g.dart` ne sont pas versionnés) :
   ```
   dart run build_runner build --delete-conflicting-outputs
   ```
3. Configurer Firebase (l'application ne démarre pas sans) :
   1. Créer un projet sur la [console Firebase](https://console.firebase.google.com).
   2. Dans *Authentication → Sign-in method*, activer **Email/Password** et **Google**.
   3. Ajouter une app Android avec le package `com.example.cartodex`.
   4. Récupérer l'empreinte SHA-1 de debug (`cd android && ./gradlew signingReport`, variant `debug`) et l'ajouter dans les paramètres de l'app Android sur la console. Google Sign-In en a besoin.
   5. Télécharger `google-services.json` et le placer dans `android/app/`.
   6. Créer la base Firestore et déployer les règles de sécurité données plus haut.
4. Générer les icônes de lancement (facultatif) :
   ```
   dart run flutter_launcher_icons
   ```
5. Lancer l'application :
   ```
   flutter run
   ```

Firebase n'est configuré que pour Android.

## Limites connues

- **Cloud.** La synchronisation porte sur les comptes et la possession. Le champ `isPrimary` n'est pas réconcilié entre appareils : un compte importé ne devient principal que si aucun compte n'existait en local.
- **Images.** Le slug des images repose sur un site non officiel. Un nom inhabituel peut donner une image introuvable, auquel cas la tuile affiche le numéro de la carte. Les cas repérés se corrigent dans `_cardSlugOverrides`.
- **Données de carte.** Les colonnes `hp`, `types` et `illustrator` existent en base mais la source actuelle ne les fournit pas.
- **Tests.** Il n'y a pas encore de suite de tests automatisés. Les premiers candidats sont les use cases de calcul (`GetCollectionStats`, `GetSetsProgress`), `SyncWithCloud` et `PocketCardsImageSlug`, qui sont de la logique pure.
- **Livraison.** L'identifiant d'application est encore `com.example.cartodex` et le build release est signé avec la clé de debug.
- **Règles Firestore.** Elles ne sont documentées qu'ici, pas versionnées dans un fichier `firestore.rules`.