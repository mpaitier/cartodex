# Cartodex

[![CI](https://github.com/mpaitier/cartodex/actions/workflows/ci.yml/badge.svg)](https://github.com/mpaitier/cartodex/actions/workflows/ci.yml)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE)

Je joue à Pokémon TCG Pocket sur plusieurs comptes, et le jeu ne permet pas de savoir facilement quelles cartes il me manque, ni sur quel compte se trouve telle ou telle carte. Cartodex est l'application Flutter que j'ai écrite pour ça : on coche ses cartes compte par compte, et l'app calcule ce qui manque, set par set et booster par booster.

L'APK Android de la dernière version est sur la page [Releases](https://github.com/mpaitier/cartodex/releases). L'interface existe en français et en anglais.

## D'où viennent les données

Le jeu n'a pas d'API publique pour lire la collection d'un joueur, donc la possession se saisit à la main. Elle est stockée dans une base SQLite locale (Drift) et ne dépend pas du catalogue : resynchroniser le référentiel ne touche jamais aux cartes cochées.

Le catalogue vient de [pokemon-tcg-pocket-database](https://github.com/flibustier/pokemon-tcg-pocket-database), un jeu de fichiers JSON servis par jsDelivr. L'app télécharge `sets.json`, `cards.extra.json`, `cards.fr.json` (noms français) et `pullRates.json` (taux de tirage) quand on le lui demande, puis tout fonctionne hors ligne. J'avais commencé avec TCGdex, mais son modèle ne sait pas dans quel booster d'un set se trouve chaque carte, alors que c'est justement l'information dont j'avais besoin.

Un compte Firebase reste facultatif. Il sert à retrouver ses comptes et sa possession sur un autre téléphone.

## Ce que fait l'app

L'accueil range les sets par série : les séries lettrées (A, B…), puis une section Deluxe et une section Promo. On passe d'une série à l'autre au swipe, par la barre du bas ou par la feuille « Toutes les séries ». En haut de chaque série, un bandeau donne les pourcentages, une barre de progression et le nombre de cartes que personne n'a encore. Sur chaque tuile de set, la bordure est coupée en deux : la moitié gauche suit les cartes losange (◆), la moitié droite les cartes alternatives (★).

Les couleurs veulent dire la même chose partout. Le violet correspond au compte principal, le jaune à ce que les comptes secondaires ajoutent, le rouge pâle aux cartes manquantes, et le vert apparaît quand le principal a tout. La plupart des compteurs se lisent « X (+Y) / Z » : X cartes au principal, Y de plus chez les secondaires, Z au total.

Dans le détail d'un set, un tap coche une carte pour le compte principal et un double-tap ouvre le choix d'un compte secondaire. L'illustration change selon la possession : en couleur pour le principal, moitié haute grisée quand seul un secondaire l'a, grisée quand personne ne l'a. Trois volets se suivent au swipe (losanges, tout, alternatives), et un panneau de filtres permet de trier par booster, rareté, possession ou type. On peut aussi pincer pour passer de 3 à 5 colonnes, ou tout cocher d'un coup avec le bouton « + ».

L'écran des comptes gère un compte principal et autant de secondaires qu'on veut. Pour chaque secondaire, on voit les cartes qu'il a et que le principal n'a pas, et un écran les détaille set par set. La liste se trie et se filtre par extension.

Les statistiques donnent la progression globale et par série, et surtout une liste de boosters à ouvrir en priorité. Le classement se fait sur le nombre moyen de cartes manquantes qu'une ouverture rapporte, calculé avec les taux de tirage du jeu.

Le filtre de raretés (Σ, ◆ ou ★) est partagé par tous les écrans : le changer sur l'accueil le change aussi dans les statistiques. La langue suit celle du téléphone par défaut, et un menu permet d'imposer le français ou l'anglais.

Côté cloud, on se connecte par email ou avec Google, et la synchronisation fusionne les comptes et les cartes avec Firestore. Elle est limitée à 4 par compte sur 24 heures glissantes, ce qui suffit largement et évite de vider le quota gratuit de Firestore.

## Stack

| Domaine | Choix |
|---|---|
| Framework | Flutter (Dart 3.13+), Material 3, thème clair et sombre |
| État | `flutter_bloc`, `equatable` |
| Injection | `get_it` |
| Erreurs | `dartz` (`Either<Failure, T>`) |
| Stockage | `drift` et `sqlite3_flutter_libs` pour les données, `shared_preferences` pour les réglages |
| Réseau | `http`, `connectivity_plus` |
| Cloud | `firebase_core`, `firebase_auth`, `google_sign_in` (v7), `cloud_firestore` |
| Images | `cached_network_image` |
| Langues | `flutter_localizations`, `intl`, fichiers ARB |
| Qualité | `flutter_lints` avec `strict-casts` et `strict-inference`, CI GitHub Actions |

## Architecture

Le code suit une Clean Architecture en trois couches, avec du MVVM dans la présentation : chaque écran a son Bloc, qui sert de ViewModel, et les widgets se contentent d'afficher ce qu'on leur donne.

```
presentation  ──►  domain  ◄──  data
 (Bloc, vues,      (entités,     (datasources,
  widgets)         use cases,     modèles,
                   interfaces     implémentations
                   de repository) de repository)
```

Le domaine ne connaît ni Flutter, ni Drift, ni Firebase. Seule la couche data sait que le catalogue vient de jsDelivr et que le cloud est Firestore. Voici par exemple le chemin d'un tap sur une carte :

```
CardGridItem (onTap)
  → SetDetailBloc (événement CardOwnershipToggled)
    → SetCardOwned (use case)
      → CardRepository (interface du domaine)
        → CardRepositoryImpl
          → CardLocalDataSource → Drift
```

Les datasources lèvent des exceptions, que les repositories transforment en `Failure` renvoyées dans un `Either`. Aucune exception technique ne remonte jusqu'à l'interface. Chaque action a son use case, avec le même contrat (`UseCase<Result, Params>`). Les calculs de progression et la limite de synchronisations en font partie, parce que ce sont des règles métier et non des accès aux données.

Les Blocs sont créés écran par écran, sauf trois qui vivent à la racine de l'app parce qu'ils concernent tout le monde : la connexion (`AuthBloc`), le filtre de raretés (`RarityScopeCubit`) et la langue (`LanguageCubit`). La possession est mise à jour de façon optimiste. L'écran change tout de suite, et revient en arrière avec un message si l'écriture en base échoue.

Aucun texte d'interface n'est écrit en dur. Tout passe par `context.l10n`, généré depuis `lib/l10n/arb/app_fr.arb` (le fichier de référence, où chaque clé est décrite) et `app_en.arb`. Les pluriels, le séparateur décimal et la place du % suivent la langue. Les logs, eux, restent en français.

Le dossier `lib/` est organisé comme suit :

```
lib/
├── main.dart                  # Firebase, injection et langue, puis runApp
├── app.dart                   # MaterialApp, thèmes, langue et Blocs globaux
├── firebase_options.dart      # Config Firebase (Android, iOS, web), générée par flutterfire
├── core/                      # Config de build, constantes, injection, erreurs, thème, utilitaires, widgets communs
├── l10n/                      # Fichiers ARB, extension context.l10n (gen/ n'est pas versionné)
├── domain/
│   ├── entities/              # PokemonCard, CardSet, Account, CollectionStats, SyncQuota…
│   ├── repositories/          # Les cinq interfaces : cartes, comptes, auth, cloud, réglages
│   ├── services/              # Règles pures : espérance par booster, taux de tirage, limite de synchro
│   └── usecases/              # Un fichier par action
├── data/
│   ├── datasources/           # Drift et réglages en local, client HTTP du catalogue
│   ├── models/                # Conversion JSON et lignes de base
│   └── repositories/          # Implémentations
└── presentation/              # Une feature par dossier : bloc/, view/, widgets/
```

## Stockage

La base locale (Drift, schéma v4) contient cinq tables :

| Table | Contenu |
|---|---|
| `card_sets` | Sets : id, nom, nombre de cartes, série, logo, boosters |
| `cards` | Cartes : id (`A1-1`, set puis numéro), nom anglais, nom français, catégorie, élément, PV, rareté, image, boosters |
| `pull_rates` | Taux de tirage par set, variante de booster, emplacement et rareté |
| `owned_cards` | Possession, une ligne par couple (carte, compte) |
| `accounts` | Comptes de jeu : UUID, nom, code ami, principal ou non, date de création |

Les boosters et les éléments d'une carte tiennent dans une chaîne séparée par des virgules. Une carte n'en a jamais plus de trois ou quatre, une table de liaison aurait été disproportionnée.

Le nom français, ajouté en v4, est rempli à la synchronisation en croisant set et numéro avec `cards.fr.json`, et seulement s'il diffère du nom anglais. Les URL d'images partent toujours du nom anglais.

En v2, les identifiants de compte sont passés d'entiers à des UUID, pour éviter les collisions entre deux téléphones qui créent un compte hors ligne. SQLite ne sait pas changer le type d'une colonne, donc la migration renomme les tables, les recrée, recopie les lignes (l'id `1` devient `"1"`) puis supprime les anciennes, le tout dans une transaction. Les vrais UUID arrivent à la première synchronisation.

Le tri des comptes, la langue choisie et l'historique des synchronisations sont gardés avec `shared_preferences` et ne quittent pas le téléphone.

Dans Firestore, chaque compte de jeu est un document, avec ses cartes dans un tableau. Une synchronisation coûte donc une lecture par compte, pas une par carte.

```
users/{userId}/accounts/{accountId}
  name: string
  gameAccountId: string
  isPrimary: bool
  createdAt: timestamp
  ownedCardIds: string[]
```

Les règles de sécurité sont dans `firestore.rules` : un utilisateur connecté ne lit et n'écrit que ses propres comptes, et une écriture qui ne respecte pas ce format est refusée. On les déploie avec `firebase deploy --only firestore:rules`.

## Quelques règles métier

Une carte est « de base » si sa rareté est un losange. Tout le reste compte comme alternatif, y compris les promos sans rareté connue. Tous les écrans passent par `CardRarity.isBase` pour afficher les mêmes chiffres.

Dans « X (+Y) / Z », une carte que plusieurs secondaires possèdent ne compte qu'une fois dans Y, et pas du tout si le principal l'a déjà. X + Y ne dépasse donc jamais Z. Le vert ne s'affiche que quand le principal a tout à lui seul.

Pour les boosters prioritaires, `BoosterExpectedValue` estime combien de cartes manquantes une ouverture rapporte en moyenne. Seul le compte principal compte dans ce calcul, puisque les cartes des secondaires ne le rendent pas moins utile pour lui. La progression d'un set côté boosters est l'union de ses boosters, pour qu'une carte présente dans deux boosters ne soit pas comptée deux fois. Les sets promo ne sont jamais recommandés. Si les taux de tirage manquent, les boosters passent en fin de liste, du moins avancé au plus avancé.

À la synchronisation du catalogue, le nombre de cartes d'un set est recalculé à partir des cartes reçues, parce que la source l'oublie parfois (c'est le cas de « Promo B »). Les cartes sont lues sur la branche `main` du référentiel, avec un repli sur la version npm figée en 2.x si GitHub ne répond pas ou si le format du fichier change.

La synchronisation cloud ne retire jamais une carte : une carte cochée d'un côté l'est des deux côtés après la fusion, et l'envoi passe par `arrayUnion` pour que Firestore applique la même règle. `SyncWithCloud` remplace d'abord les anciens identifiants par des UUID, compare ensuite chaque compte avec le cloud, et importe pour finir les comptes qui n'existent qu'en ligne. Une erreur arrête tout sans rien annuler, mais la fusion donne le même résultat si on la rejoue, donc la synchronisation suivante rattrape ce qui manque.

La limite de 4 synchronisations sur 24 heures est vérifiée par `SyncRateLimit` avant toute lecture du cloud. Une synchronisation qui échoue ne compte pas. L'historique reste sur le téléphone : réinstaller l'app ou changer l'heure permet de la contourner, mais ce n'est pas son but, elle sert à éviter qu'un bug ou un doigt trop pressé lance des synchros en boucle.

Le référentiel ne donne pas d'URL d'images. `PocketCardsImageSlug` les reconstruit à partir des noms, sur le modèle de [pocketcards.net](https://pocketcards.net), en se basant sur des exemples observés puisque le site n'a pas d'API. Il gère les noms collés (« Teal MaskOgerpon »), les formes régionales (« Galarianzigzagoon »), les chiffres en fin de nom (« Porygon2 »), et garde une table de correctifs pour le reste. En debug, chaque image introuvable est signalée dans la console.

## Lancer le projet

Il faut un SDK Flutter récent (Flutter 3.47 et Dart 3.13 au minimum) et, pour la partie cloud, un projet Firebase.

```
flutter pub get
dart run build_runner build
flutter run
```

`flutter pub get` génère aussi les textes traduits dans `lib/l10n/gen/`. `build_runner` génère le code Drift (les `*.g.dart`). Aucun des deux n'est versionné.

Le dépôt contient la configuration Firebase de mon projet. Pour utiliser le vôtre, créez un projet sur la [console Firebase](https://console.firebase.google.com), activez la connexion par email et par Google dans *Authentication*, puis générez la configuration avec la [CLI FlutterFire](https://firebase.google.com/docs/flutter/setup) :

```
dart pub global activate flutterfire_cli
flutterfire configure --project=<id-du-projet> --platforms=android,ios,web --android-package-name=com.mpaitier.cartodex --ios-bundle-id=com.mpaitier.cartodex
```

Elle écrit `lib/firebase_options.dart` et `android/app/google-services.json`. Il reste ensuite à déclarer les empreintes SHA-1 et SHA-256 de vos clés dans les paramètres de l'app Android (`cd android && ./gradlew signingReport` pour celle de debug), sans quoi la connexion Google échoue. Créez enfin la base Firestore et déployez les règles avec `firebase deploy --only firestore:rules` (la CLI s'installe avec `npm install -g firebase-tools`).

### Release Android

La release est signée avec une clé à part, qui ne doit jamais entrer dans le dépôt. Pour la créer :

```
keytool -genkey -v -keystore <chemin>/cartodex-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cartodex
```

Copiez ensuite `android/key.properties.example` en `android/key.properties` et remplissez-le. Gardez une sauvegarde de la clé : si elle est perdue, plus aucune mise à jour n'est possible sous le même identifiant. Le build se lance avec :

```
flutter build apk --release --split-per-abi
```

Sans `key.properties`, Gradle signe avec la clé de debug et affiche un avertissement. L'APK marche, mais il n'est pas fait pour être distribué.

### iOS

Le projet iOS compile (iOS 15 minimum, imposé par Firebase), et la CI le vérifie sur macOS à chaque pull request. Je ne l'ai jamais lancé sur un iPhone, faute de Mac. La connexion Google y demandera en plus l'identifiant client OAuth iOS dans `Info.plist`.

## Tests

Les tests couvrent tout ce qui n'est pas de l'interface : les règles du domaine (progression, raretés, espérance par booster, limite de synchro), les use cases (`GetCollectionStats`, `GetSetsProgress`, `SyncWithCloud`, `GetSyncQuota`), les modèles, les utilitaires et les états des Blocs. Les repositories sont remplacés par des faux en mémoire (`test/helpers/fake_repositories.dart`), donc aucun test ne touche à Drift, à Firebase ou au réseau.

```
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter analyze
flutter test
```

Pensez à relancer `flutter gen-l10n` après avoir touché aux fichiers ARB, sinon l'analyse ne trouve pas les nouvelles clés.

La CI (`.github/workflows/ci.yml`) refait tout ça à chaque push sur `main` et sur chaque pull request, avec `flutter analyze --fatal-infos` : une seule remarque du linter fait échouer le run. Deux jobs compilent ensuite l'app, un APK sur Linux et l'app iOS sans signature sur macOS.

## Limites actuelles

Seul Android est testé et distribué. iOS compile sans avoir été essayé, et le web n'est pas encore pris en charge.

Le fichier `cards.fr.json` du référentiel ne traduit pour l'instant qu'une petite partie des cartes (environ 90, surtout des promos, au 10/11/2026), et rien des dernières extensions. Le reste s'affiche en anglais, et les noms se complèteront tout seuls quand la source sera enrichie. Les noms de sets sont encore en anglais.

Certaines images restent introuvables quand un nom ne suit pas la convention du site (le logo de « Special Pack First Partners », par exemple). La tuile affiche alors le numéro de la carte ou une icône, et le cas se corrige dans les tables de `PocketCardsImageSlug`.

Les messages d'erreur qui viennent de la couche data (connexion, stockage, réseau) sont toujours en français, même quand l'app est en anglais. Le champ `isPrimary` n'est pas réconcilié entre appareils, et la colonne `illustrator` reste vide parce que la source ne la fournit pas. Il n'y a pas encore de tests de widgets ni de tests d'intégration.

## Pour la suite

J'aimerais une version web, plus pratique pour cocher des cartes depuis un ordinateur. La configuration Firebase est prête, mais Drift sur le web demande SQLite compilé en WebAssembly, la connexion Google y fonctionne autrement, et il faudra vérifier que pocketcards.net accepte qu'on charge ses images depuis un autre domaine. Viendront aussi des erreurs typées pour traduire les messages restants, et les noms de sets en français, que `sets.json` fournit déjà.

## Licence

Le code est sous licence [MIT](LICENSE). Pokémon et Pokémon TCG Pocket sont des marques de leurs propriétaires respectifs. Ce projet personnel n'est ni affilié à The Pokémon Company, Nintendo, Creatures ou GAME FREAK, ni approuvé par eux. Les données de cartes viennent de [pokemon-tcg-pocket-database](https://github.com/flibustier/pokemon-tcg-pocket-database) et les images de [pocketcards.net](https://pocketcards.net).
