# Cartodex

[![CI](https://github.com/mpaitier/cartodex/actions/workflows/ci.yml/badge.svg)](https://github.com/mpaitier/cartodex/actions/workflows/ci.yml)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE)

Application mobile Flutter pour suivre sa collection de cartes Pokémon TCG Pocket, sur un ou plusieurs comptes de jeu, avec synchronisation facultative entre appareils. Interface en français et en anglais.

La dernière version se télécharge depuis la page [Releases](https://github.com/mpaitier/cartodex/releases) (APK Android).

## Contexte

Pokémon TCG Pocket n'expose aucune API publique qui permette de récupérer la collection d'un joueur. Cartodex combine donc trois sources, chacune avec un rôle précis :

- **Catalogue des cartes** : [pokemon-tcg-pocket-database](https://github.com/flibustier/pokemon-tcg-pocket-database), des fichiers JSON statiques servis par jsDelivr (`sets.json`, `cards.extra.json`, `cards.fr.json` pour les noms français, `pullRates.json` pour les taux de tirage). Il est téléchargé à la demande, puis stocké en local.
- **Possession des cartes** : saisie à la main par l'utilisateur, stockée uniquement dans une base SQLite locale (Drift). Elle ne dépend jamais du catalogue : une resynchronisation complète du référentiel n'y touche pas.
- **Compte applicatif** (facultatif) : Firebase Auth et Firestore, pour retrouver ses comptes et sa possession sur un autre appareil.

L'application fonctionne entièrement hors ligne une fois le catalogue téléchargé, et sans compte applicatif.

TCGdex avait été essayé en premier. Son modèle ne décrit pas la répartition des cartes par booster à l'intérieur d'un set, alors que chaque set de TCG Pocket se décline en plusieurs boosters au contenu différent. `pokemon-tcg-pocket-database` fournit cette information, et la synchronisation passe d'une requête par carte à quelques fichiers au total.

## Fonctionnalités

Un même code couleur sert partout : violet pour le compte principal, jaune pour ce que les comptes secondaires ajoutent, rouge pâle pour les cartes que personne ne possède, vert quand le principal a tout.

**Accueil**
- Synchronisation manuelle du référentiel depuis la barre du haut, avec indicateur de chargement. L'ouverture de l'écran ne dépend jamais du réseau.
- Une page par série, du plus récent au plus ancien : séries lettrées (A, B, …), puis une section Deluxe et une section Promo. On passe de l'une à l'autre au swipe, par la barre du bas (séries récentes) ou par la feuille « Toutes les séries », qui affiche la complétion de chacune.
- En haut de chaque série, un bandeau résume la progression : pourcentages du principal, de l'apport des secondaires et du total, barre de progression, nombre de cartes manquantes et détail « X (+Y) / Z ».
- Chaque tuile de set affiche son logo, son nombre de cartes et de boosters, et une bordure de progression coupée en deux : la moitié gauche suit les cartes losange (◆), la moitié droite les cartes alternatives (★). Les pourcentages sont écrits sous la tuile.
- Un seul filtre de raretés (Σ toutes, ◆ losange, ★ étoile) vaut pour toute l'application. On le change depuis le bandeau d'une série, la barre des statistiques ou un swipe dans le détail d'un set, et tous les écrans suivent.

**Détail d'un set**
- Trois volets au swipe : cartes losange à gauche, toutes les cartes au milieu, cartes alternatives à droite. L'écran s'ouvre sur le volet du filtre de raretés courant.
- L'illustration reflète la possession : en couleur pour le compte principal, moitié haute grisée pour une carte qu'un secondaire est seul à avoir, entièrement grisée pour une carte manquante. Un badge le rappelle sur chaque tuile.
- Tap simple : bascule la possession pour le compte principal. Double-tap : choix d'un compte secondaire.
- Panneau de filtres, avec une pastille qui indique combien sont actifs : booster, rareté (multi-sélection), possession (tout, principal, secondaires, manquantes, avec un sous-filtre par compte secondaire) et type (éléments des Pokémon, types de Dresseur).
- Pincement à deux doigts : la grille passe de 3 à 5 colonnes (illustration et badge seuls), et revient à 3 dans l'autre sens.
- Bouton « + » : marque d'un coup, après confirmation, les cartes affichées pour le compte principal.
- Titre avec les compteurs ◆ / ★ / Σ. Un tap bascule entre « principal seul » et « principal + secondaires ».
- Nom des cartes en français quand l'application est en français et que le référentiel fournit une traduction, en anglais sinon.

**Comptes**
- Plusieurs comptes de jeu suivis dans la même application, dont un seul est principal (étoile pleine). Le principal se change en un tap.
- Nom et code ami modifiables. Le code ami n'est affiché nulle part ailleurs.
- Chaque compte secondaire montre ses cartes en plus du principal (losanges et étoiles) et les logos des trois sets où il en a le plus.
- Tri (ordre de création, alphabétique, cartes en plus) et filtre par extension, le principal restant toujours en tête. Le tri est mémorisé.
- Pour chaque secondaire, un écran liste les sets où il possède des cartes que le principal n'a pas. Un tap sur un set ouvre son détail restreint à ces cartes.

**Statistiques**
- Progression globale et par série, au format « X (+Y) / Z ».
- Boosters à ouvrir en priorité, filtrables par série : ils sont classés selon le nombre moyen de cartes manquantes qu'une ouverture rapporte, d'après les taux de tirage du jeu. Un tap ouvre le détail du set.
- Un bouton fait tourner le périmètre de raretés (toutes, losange, étoile), le même filtre que sur l'accueil.

**Langue**
- Interface en français et en anglais. Par défaut, l'application suit la langue du téléphone, et l'anglais pour toute autre langue.
- Un menu de l'accueil permet d'imposer le français ou l'anglais. Le choix est mémorisé.

**Synchronisation cloud**
- Connexion par email et mot de passe, ou par Google.
- Fusion des comptes et de la possession avec Firestore, avec un bilan affiché à la fin (« 2 comptes récupérés, 14 cartes envoyées »).
- Au plus 4 synchronisations sur 24 heures glissantes par compte. Le menu indique combien il en reste, puis l'heure de la prochaine possible une fois la limite atteinte.

## Stack technique

| Domaine | Choix |
|---|---|
| Framework | Flutter (Dart 3.13+, voir `pubspec.lock`), Material 3, thème clair et sombre |
| État | `flutter_bloc` (Bloc et Cubit), `equatable` |
| Injection de dépendances | `get_it` |
| Gestion des erreurs | `dartz` (`Either<Failure, T>`) |
| Persistance locale | `drift` + `sqlite3_flutter_libs` pour les données, `shared_preferences` pour les réglages |
| Réseau | `http`, `connectivity_plus` |
| Compte et cloud | `firebase_core`, `firebase_auth`, `google_sign_in` (v7), `cloud_firestore` |
| Images | `cached_network_image` |
| Localisation | `flutter_localizations`, `intl`, fichiers ARB compilés par `flutter gen-l10n` |
| Identifiants | `uuid` |
| Qualité | `flutter_lints`, `strict-casts` et `strict-inference`, CI GitHub Actions |

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

- **Erreurs.** Les datasources lèvent des exceptions (`ServerException`, `CacheException`, `AuthException`). Les repositories les convertissent en `Failure`, renvoyées sous forme de `Either` : aucune exception technique ne remonte au domaine ni à l'interface.
- **Use cases.** Un fichier par action, avec un contrat commun (`UseCase<Result, Params>`). Les calculs de complétion (`GetCollectionStats`, `GetSetsProgress`, `GetSecondaryAccountsExtras`) et la limite de synchronisations sont des règles métier : ils vivent dans le domaine, pas dans un repository ni dans un Bloc. `WatchAuthState` fait exception au contrat : c'est un flux continu, pas un `Future`.
- **Injection.** Services, datasources, repositories et use cases sont des singletons paresseux. Les Blocs sont enregistrés en factory, une instance par écran, sauf `AuthBloc`, `RarityScopeCubit` et `LanguageCubit` : la connexion, le périmètre de raretés et la langue sont des états de toute l'application, fournis une fois à la racine.
- **Mises à jour optimistes.** La bascule de possession change l'état immédiatement, puis revient en arrière avec un message si l'écriture locale échoue. L'ajout en masse est tout ou rien.
- **Composants.** Chaque écran est découpé en petits widgets sans connaissance du Bloc parent : ils reçoivent leurs données et remontent les interactions par callbacks.
- **Textes.** Aucun texte d'interface n'est écrit en dur dans les widgets. Ils passent tous par `context.l10n` (voir `lib/l10n/l10n.dart`), généré à partir de `lib/l10n/arb/app_fr.arb` (langue de référence, avec la description de chaque clé) et `app_en.arb`. Les pluriels, le séparateur décimal et la place du signe % suivent la langue. Les énumérations du domaine ne portent aucun libellé : des extensions de présentation s'en chargent (`CardKindStyle`, `AccountsSortOptionLabel`, `AppLanguageLabel`). Les messages de log restent en français, ils ne s'adressent qu'au développeur.

## Structure du projet

```
lib/
├── main.dart                  # Initialisation Firebase, injection et langue, puis runApp
├── app.dart                   # MaterialApp, thèmes, langue ; AuthBloc, RarityScopeCubit, LanguageCubit à la racine
├── firebase_options.dart      # Configuration Firebase (Android, iOS, web), générée par flutterfire configure
├── core/
│   ├── config/                # BuildConfig (réglages passés au build)
│   ├── constants/             # AppConstants (URLs, nom de la base), CardRarity, RarityAssets
│   ├── di/                    # injection_container.dart (get_it)
│   ├── error/                 # Exceptions et Failures
│   ├── network/               # NetworkInfo (abstraction de la connectivité)
│   ├── theme/                 # AppColors, AppTheme, filtres de couleur
│   ├── utils/                 # AppLogger, PocketCardsImageSlug, PercentFormatter, PackDisplayName
│   └── widgets/               # AppScaffold, AppLoadingIndicator, AppErrorView, symboles de rareté
├── l10n/
│   ├── arb/                   # app_fr.arb (référence) et app_en.arb
│   ├── gen/                   # AppLocalizations, généré par flutter gen-l10n (non versionné)
│   └── l10n.dart              # Extension context.l10n et langues proposées
├── domain/
│   ├── entities/              # PokemonCard, CardSet, Account, CollectionStats, ProgressCount, SetProgress,
│   │                          # RarityScope, SyncQuota, AppLanguage…
│   ├── repositories/          # Card, Account, Auth, CloudSync et UserPreferences (interfaces)
│   ├── services/              # BoosterExpectedValue, PullRateRarity, SyncRateLimit (règles pures)
│   └── usecases/              # Un fichier par action (catalogue, comptes, statistiques, auth, synchro, réglages)
├── data/
│   ├── datasources/
│   │   ├── local/             # AppDatabase (Drift), tables, datasources cartes, comptes et réglages
│   │   └── remote/            # Client HTTP du catalogue
│   ├── models/                # CardModel, CardSetModel, SetPullRatesModel, AccountModel, CloudAccountModel…
│   └── repositories/          # Implémentations des cinq repositories
└── presentation/
    ├── card_sets/             # Accueil : séries, sets, synchronisations
    ├── set_detail/            # Détail d'un set : cartes, filtres, possession
    ├── accounts/              # Gestion des comptes de jeu
    ├── account_extras/        # Cartes qu'un secondaire possède en plus du principal
    ├── stats/                 # Statistiques de complétion
    ├── rarity_scope/          # Filtre de raretés Σ / ◆ / ★ commun à toute l'app
    ├── language/              # Choix de la langue d'affichage
    ├── auth/                  # Connexion au compte applicatif
    └── sync/                  # Synchronisation cloud et quota de synchronisations
```

Chaque feature de `presentation/` suit le même découpage : `bloc/` (événements, état, Bloc), `view/` (la page) et `widgets/` (les composants).

## Modèle de données

### Base locale (Drift, schéma v4)

| Table | Rôle |
|---|---|
| `card_sets` | Sets du référentiel : id, nom, nombre de cartes, série, logo, boosters |
| `cards` | Cartes du référentiel : id (`A1-1`, set et numéro), nom anglais, nom français (facultatif), catégorie, élément, PV, set, image, rareté, boosters |
| `pull_rates` | Probabilités de tirage : set, variante de booster, emplacement, rareté, taux |
| `owned_cards` | Possession, clé composite (`card_id`, `account_id`) |
| `accounts` | Comptes de jeu suivis : id (UUID), nom, code ami, principal ou non, date de création |

Les listes (boosters, éléments) sont stockées en une chaîne séparée par des virgules : une carte n'a jamais que quelques valeurs, une table relationnelle serait disproportionnée.

**Nom français (v4).** La colonne `name_fr` de `cards` est remplie à la synchronisation du référentiel, par rapprochement sur le set et le numéro avec `cards.fr.json`, et seulement quand le nom diffère du nom anglais. Le nom anglais reste la seule base des URL d'illustrations.

**Migration v1 → v2.** Les identifiants de compte passent d'entiers auto-incrémentés à des UUID, pour qu'un compte créé hors ligne sur deux appareils ne puisse pas entrer en collision au moment de la synchronisation. SQLite ne sait pas changer le type d'une colonne en place : les deux tables concernées sont renommées, recréées au schéma courant, remplies par copie (l'id `1` devient `"1"`) puis supprimées, dans une transaction. Les anciens comptes reçoivent de vrais UUID au premier passage dans `SyncWithCloud`.

### Réglages de l'appareil

Gardés avec `shared_preferences`, jamais envoyés dans le cloud : le tri de la liste des comptes, la langue choisie et l'historique des synchronisations de chaque compte applicatif (pour la limite de synchronisations).

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

Les règles de sécurité sont versionnées dans `firestore.rules`. Chaque utilisateur connecté ne lit et ne modifie que ses propres comptes, et une écriture n'est acceptée que si le document garde la forme ci-dessus (champs connus, types attendus). Tout le reste de la base est refusé. Elles se déploient avec la CLI Firebase, le projet par défaut étant déclaré dans `.firebaserc` :

```
firebase deploy --only firestore:rules
```

## Règles métier

**Possession.** Elle est propre à chaque compte. Le tap simple agit sur le compte principal, le double-tap sur un secondaire choisi dans une liste. Il y a toujours exactement un compte principal dès qu'au moins un compte existe, et le premier compte créé le devient automatiquement.

**Losange et alternatif.** Une carte est « de base » si sa rareté est de groupe losange. Tout le reste (étoile, couronne, chromatique, et cartes sans rareté connue comme certaines promos) est « alternatif ». Toute l'application passe par `CardRarity.isBase`, pour que les écrans affichent les mêmes chiffres.

**Progression « X (+Y) / Z ».** Y compte les cartes possédées par au moins un secondaire et pas par le principal, sans doublon même si plusieurs secondaires la possèdent. X + Y ne dépasse donc jamais Z. La barre ou la bordure passe au vert seulement quand le principal possède, à lui seul, tout le groupe.

**Boosters prioritaires.** Pour chaque booster, `BoosterExpectedValue` calcule le nombre moyen de cartes manquantes qu'une ouverture rapporte, à partir des taux de tirage du set (`pullRates.json`). Les boosters, et les sets qui les regroupent, sont classés selon ce nombre. Sans taux connus, ils passent après les autres, du moins avancé au plus avancé. La progression d'un set côté boosters est l'union de ses boosters : une carte présente dans plusieurs boosters ne compte qu'une fois. Les sets promotionnels et les sets sans booster connu sont exclus. Seul le compte principal compte, puisque les cartes des secondaires ne rendent pas un booster moins utile pour lui.

**Synchronisation du catalogue.** Le total de cartes d'un set est recalculé à partir des cartes réellement récupérées, car la source l'omet pour certains sets (« Promo B ») ou peut diverger. Les cartes sont lues sur la branche `main` du dépôt du référentiel, avec repli sur la version npm figée en 2.x si GitHub ne répond pas ou si le format du fichier change.

**Synchronisation cloud.** La règle de fusion est que « possédée » l'emporte toujours : une carte marquée possédée d'un côté l'est des deux après synchronisation, et aucune carte n'est jamais démarquée. L'envoi utilise `arrayUnion` côté Firestore, pour que la règle tienne même côté serveur. Déroulé de `SyncWithCloud` :

1. Remplacement des identifiants hérités (simples nombres) par des UUID.
2. Comparaison compte par compte : envoi de ce qui manque au cloud, récupération de ce qui manque en local.
3. Import des comptes qui n'existent que dans le cloud.

Le traitement s'arrête à la première erreur sans revenir en arrière. La fusion étant idempotente, une nouvelle synchronisation rattrape le reste.

**Limite de synchronisations.** `SyncRateLimit` autorise 4 synchronisations réussies sur une fenêtre glissante de 24 heures, par compte applicatif. `SyncWithCloud` vérifie le quota avant toute lecture du cloud et renvoie une `SyncQuotaExceededFailure` au-delà. Une synchronisation en échec n'est pas comptée. L'historique est gardé sur l'appareil : la limite protège le quota Firestore d'un usage en boucle, sans prétendre résister à une réinstallation ou à un changement d'heure volontaire.

**Images.** La source ne fournit aucune URL exploitable. Les illustrations de cartes, logos de sets et icônes de boosters sont reconstruits à partir des noms du référentiel via `PocketCardsImageSlug`, sur le modèle de [pocketcards.net](https://pocketcards.net). Le site n'a pas d'API documentée : la conversion est déduite d'exemples observés. Elle gère les noms collés (« Teal MaskOgerpon »), les préfixes de forme régionale (« Galarianzigzagoon »), les chiffres en fin de nom (« Porygon2 ») et dispose d'une table de correctifs manuels. En debug, `AppLogger` signale chaque image introuvable.

## Installation

Prérequis : un SDK Flutter compatible avec `pubspec.lock` (Dart 3.13 et Flutter 3.47 au minimum) et un projet Firebase.

1. Récupérer les dépendances. La commande génère aussi les textes traduits dans `lib/l10n/gen/` (non versionné) :
   ```
   flutter pub get
   ```
2. Générer le code Drift (les fichiers `*.g.dart` ne sont pas versionnés) :
   ```
   dart run build_runner build
   ```
3. Configurer Firebase. Le dépôt contient la configuration du projet de l'auteur ; pour utiliser son propre projet :
   1. Créer un projet sur la [console Firebase](https://console.firebase.google.com).
   2. Dans *Authentication → Sign-in method*, activer **Email/Password** et **Google**.
   3. Générer la configuration avec la [CLI FlutterFire](https://firebase.google.com/docs/flutter/setup). Elle enregistre les apps dans le projet, écrit `lib/firebase_options.dart` et `android/app/google-services.json`, et met à jour `firebase.json` :
      ```
      dart pub global activate flutterfire_cli
      flutterfire configure --project=<id-du-projet> --platforms=android,ios,web --android-package-name=com.mpaitier.cartodex --ios-bundle-id=com.mpaitier.cartodex
      ```
   4. Ajouter dans les paramètres de l'app Android, sur la console, les empreintes SHA-1 et SHA-256 de la clé de debug (`cd android && ./gradlew signingReport`, variante `debug`) et de la clé de release (voir plus bas). Google Sign-In refuse la connexion depuis un APK dont l'empreinte n'est pas déclarée.
   5. Créer la base Firestore, puis déployer les règles de sécurité avec `firebase deploy --only firestore:rules` (CLI installée par `npm install -g firebase-tools`, connexion par `firebase login`).
4. Générer les icônes de lancement (facultatif) :
   ```
   dart run flutter_launcher_icons
   ```
5. Lancer l'application :
   ```
   flutter run
   ```

### Build de release Android

La release est signée avec une clé propre au projet, jamais versionnée. Pour la créer une fois (la garder hors du dépôt et la sauvegarder : sans elle, impossible de publier une mise à jour) :

```
keytool -genkey -v -keystore <chemin>/cartodex-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cartodex
```

Copier ensuite `android/key.properties.example` en `android/key.properties` et y renseigner les mots de passe, l'alias et le chemin de la clé. Les empreintes à déclarer dans Firebase s'affichent avec `keytool -list -v -keystore <chemin>/cartodex-release.jks -alias cartodex`. Puis, pour un APK par architecture (plus léger qu'un APK universel) :

```
flutter build apk --release --split-per-abi
```

Sans `android/key.properties`, le build retombe sur la clé de debug avec un avertissement dans la console Gradle : un tel APK sert aux essais, pas à la diffusion.

### iOS

Le projet iOS compile (iOS 15 minimum, imposé par Firebase), et la CI le vérifie à chaque pull request avec `flutter build ios --release --no-codesign`. Il n'a encore jamais été lancé sur un iPhone : la connexion Google y demande en plus l'identifiant client OAuth iOS dans `Info.plist`, non configuré à ce jour.

## Tests et intégration continue

Les tests portent sur la logique sans interface : règles du domaine (progression, raretés, espérance de cartes par booster, limite de synchronisations), use cases (`GetCollectionStats`, `GetSetsProgress`, `SyncWithCloud`, `GetSyncQuota`), modèles de données, utilitaires (`PocketCardsImageSlug`, `PercentFormatter`) et états des Blocs et Cubits. Les dépôts sont remplacés par des faux en mémoire (`test/helpers/fake_repositories.dart`) : aucun test ne touche à Drift, à Firebase ou au réseau.

Pour tout lancer en local, dans cet ordre (le code généré doit exister avant l'analyse) :

```
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter analyze
flutter test
```

`flutter gen-l10n` est à relancer après chaque modification des fichiers ARB, sinon l'analyse signale les nouvelles clés comme inconnues.

La CI GitHub Actions (`.github/workflows/ci.yml`) refait ces étapes à chaque push sur `main` et sur chaque pull request, avec `flutter analyze --fatal-infos` : la moindre remarque du linter fait échouer le run. Si elles passent, deux jobs compilent ensuite l'app : un APK release sur Linux (signé avec la clé de debug, faute de secret) et l'app iOS sans signature sur macOS.

## Limites connues

- **Plateformes.** Seul Android est testé et distribué. iOS compile mais n'a jamais été lancé sur un appareil (voir plus haut). Le web n'est pas encore pris en charge.
- **Cloud.** La synchronisation porte sur les comptes et la possession. Le champ `isPrimary` n'est pas réconcilié entre appareils : un compte importé ne devient principal que si aucun compte n'existait en local.
- **Noms français.** Au 10/11/2026, `cards.fr.json` ne traduit qu'une petite partie du catalogue (environ 90 cartes, surtout des promos B) et ne couvre pas les extensions les plus récentes. Les autres cartes s'affichent en anglais, même avec l'application en français. Les noms se complètent d'eux-mêmes à la synchronisation suivante quand le fichier source est enrichi. Les noms de sets restent en anglais.
- **Images.** Le slug des images repose sur un site non officiel. Un nom inhabituel peut donner une image introuvable : la tuile affiche alors le numéro de la carte, et un logo de set manquant (c'est le cas de « Special Pack First Partners ») est remplacé par une icône. Les cas repérés se corrigent dans les tables de correctifs de `PocketCardsImageSlug`.
- **Données de carte.** La colonne `illustrator` existe en base mais la source ne la fournit pas.
- **Messages d'erreur.** Les erreurs remontées par la couche data (connexion, stockage local, réseau) s'affichent en français, même avec l'application en anglais.
- **Tests.** Il n'y a ni tests de widgets ni tests d'intégration : l'interface se vérifie encore à la main.

## Pistes

- **Version web**, pour un usage plus fluide sur ordinateur. `firebase_options.dart` contient déjà la configuration web. Restent la base locale (Drift sur le web demande SQLite compilé en WebAssembly et un worker), la connexion Google, qui suit un autre parcours sur le web, et le chargement des images de pocketcards.net depuis un autre domaine.
- **Erreurs typées**, pour traduire les messages de la couche data.
- **Noms de sets en français** : `sets.json` les fournit déjà.

## Licence

Code distribué sous licence [MIT](LICENSE). Pokémon et Pokémon TCG Pocket sont des marques de leurs propriétaires respectifs. Ce projet personnel n'est ni affilié à The Pokémon Company, Nintendo, Creatures ou GAME FREAK, ni approuvé par eux. Les données de cartes viennent de [pokemon-tcg-pocket-database](https://github.com/flibustier/pokemon-tcg-pocket-database) et les images de [pocketcards.net](https://pocketcards.net).
