# Cartodex

Application mobile Flutter pour suivre sa collection de cartes Pokémon TCG Pocket.

## Contexte

Pokémon TCG Pocket n'expose aucune API publique permettant de récupérer la collection d'un compte joueur. Cartodex s'appuie donc sur deux sources de données distinctes :

- **[TCGdex](https://tcgdex.dev/fr/tcg-pocket)** : référentiel de toutes les cartes existantes dans le jeu (nom, image, set, rareté, booster). Synchronisé via un bouton dans l'application.
- **Base locale (Drift)** : la possession de chaque carte, saisie manuellement par l'utilisateur et stockée uniquement sur l'appareil.

## Architecture

Clean Architecture en trois couches, avec MVVM côté présentation (chaque écran est piloté par un Bloc/Cubit qui joue le rôle de ViewModel).

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
│   │   └── remote/         # Client API TCGdex : catalogue uniquement
│   ├── models/              # DTO avec fromJson/toJson (CardModel, CardSetModel)
│   └── repositories/         # CardRepositoryImpl
└── presentation/
    └── <feature>/
        ├── bloc/              # ViewModel (Bloc/Cubit)
        ├── view/               # Écrans
        └── widgets/             # Composants spécifiques à la feature
```

Règle de dépendance : `presentation` → `domain` ← `data`. Le domaine ne connaît jamais Flutter, Drift ou l'API ; il ne dépend que de ses propres interfaces.

Note de nommage : l'entité carte s'appelle `PokemonCard` (et non `Card`) pour éviter toute collision avec le widget Material `Card`. Pour la même raison, la ligne Drift générée pour la table `Cards` est explicitement nommée `CardRow` via `@DataClassName`.

## État actuel

Les fondations sont posées : structure du projet, thème, gestion d'erreurs, composants UI génériques.

La couche domaine du catalogue de cartes est posée : entités `CardCategory`, `CardSet`, `PokemonCard` ; interface `CardRepository` ; use cases `SyncCardCatalog`, `GetCardSets`, `GetCardsBySet`, `GetOwnedCardIds`, `SetCardOwned`.

La couche data du catalogue de cartes est posée :
- **Remote** : `CardRemoteDataSource`, qui interroge TCGdex (`/series/tcgp` pour les sets, `/sets/{id}` puis `/cards/{id}` pour le détail complet de chaque carte — l'API ne renvoie que des références légères au niveau d'un set).
- **Local** : base Drift (`AppDatabase`) avec trois tables — `CardSets`, `Cards` (référentiel) et `OwnedCards` (possession, volontairement séparée et jamais affectée par une resynchronisation) — exposées via `CardLocalDataSource`.
- **Repository** : `CardRepositoryImpl`, qui synchronise depuis TCGdex vers Drift, et qui ne lit/écrit plus qu'en local une fois la synchronisation faite.
- Câblage dans `injection_container.dart` (core, datasources, repository).

Prochaine étape : enregistrer les use cases dans `injection_container.dart`, puis la couche présentation (Bloc/Cubit + écrans) de la liste des sets et de la collection.

## Mise en route

Ce projet a été rédigé à la main, sans exécution locale de `flutter create` ni `flutter pub get` (l'environnement de génération n'a pas accès au SDK Flutter ni à pub.dev). Pour le lancer :

1. Créer un nouveau projet Flutter vierge : `flutter create cartodex`
2. Remplacer le `pubspec.yaml` généré par celui fourni ici, et copier le contenu de `lib/` par-dessus celui généré.
3. Copier `analysis_options.yaml` et `.gitignore` à la racine.
4. Installer les dépendances : `flutter pub get`
5. Générer le code Drift : `dart run build_runner build --delete-conflicting-outputs`
6. Lancer l'application : `flutter run`