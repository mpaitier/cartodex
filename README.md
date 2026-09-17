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
│   ├── entities/
│   ├── repositories/      # Interfaces abstraites
│   └── usecases/
├── data/                   # Implémentation technique du domaine
│   ├── datasources/
│   │   ├── local/          # DAO Drift
│   │   └── remote/         # Client API TCGdex
│   ├── models/              # DTO avec fromJson/toJson
│   └── repositories/         # Implémentations concrètes
└── presentation/
    └── <feature>/
        ├── bloc/              # ViewModel (Bloc/Cubit)
        ├── view/               # Écrans
        └── widgets/             # Composants spécifiques à la feature
```

Règle de dépendance : `presentation` → `domain` ← `data`. Le domaine ne connaît jamais Flutter, Drift ou l'API ; il ne dépend que de ses propres interfaces.

## État actuel

Les fondations sont posées : structure du projet, thème, gestion d'erreurs, squelette d'injection de dépendances, composants UI génériques. Les couches domaine et data pour le catalogue de cartes arrivent à l'étape suivante.

## Mise en route

Ce projet a été rédigé à la main, sans exécution locale de `flutter create` ni `flutter pub get` (l'environnement de génération n'a pas accès au SDK Flutter ni à pub.dev). Pour le lancer :

1. Créer un nouveau projet Flutter vierge : `flutter create cartodex`
2. Remplacer le `pubspec.yaml` généré par celui fourni ici, et copier le contenu de `lib/` par-dessus celui généré.
3. Copier `analysis_options.yaml` et `.gitignore` à la racine.
4. Installer les dépendances : `flutter pub get`
5. Lancer l'application : `flutter run`

Une fois la couche data (Drift) ajoutée, une étape supplémentaire sera nécessaire : `dart run build_runner build --delete-conflicting-outputs` pour générer le code de la base de données.
