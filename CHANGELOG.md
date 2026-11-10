# Changelog

Toutes les évolutions notables de Cartodex sont consignées ici. Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) et le projet respecte le [versionnage sémantique](https://semver.org/lang/fr/).

## [1.0.0] - 2026-11-10

Première version publique.

### Catalogue
- Référentiel de cartes Pokémon TCG Pocket téléchargé à la demande depuis pokemon-tcg-pocket-database, puis consultable hors ligne.
- Accueil rangé par série (séries lettrées, Deluxe, Promo), avec swipe entre séries, feuille « Toutes les séries » et bandeau de progression par série.
- Tuiles de set avec bordure de progression losange / étoile.
- Filtre de raretés Σ / ◆ / ★ commun à toute l'application.

### Détail d'un set
- Trois volets (losange, tout, alternatif), possession par tap (compte principal) et double-tap (compte secondaire).
- Illustrations colorées, à moitié grisées ou grisées selon la possession.
- Panneau de filtres : booster, rareté, possession, type.
- Grille à 3 ou 5 colonnes au pincement, ajout en masse des cartes affichées.
- Noms de cartes en français quand le référentiel en fournit.

### Comptes et statistiques
- Plusieurs comptes de jeu, un principal et des secondaires, avec les cartes que chaque secondaire possède en plus.
- Tri et filtre par extension de la liste des comptes, modification du nom et du code ami.
- Progression globale et par série au format « X (+Y) / Z ».
- Boosters à ouvrir en priorité, classés selon le nombre moyen de cartes manquantes par ouverture, d'après les taux de tirage.

### Synchronisation cloud
- Compte applicatif Firebase (email ou Google) et fusion des comptes et de la possession avec Firestore.
- Limite de 4 synchronisations sur 24 heures glissantes par compte.
- Règles de sécurité Firestore versionnées dans le dépôt.

### Application
- Interface en français et en anglais, langue au choix dans l'application.
- Identifiant d'application définitif `com.mpaitier.cartodex` et release Android signée.
- Projet iOS compilable (iOS 15 minimum), vérifié par la CI mais pas encore testé sur appareil.
- Tests unitaires du domaine, des use cases et des Blocs, et CI GitHub Actions (analyse, tests, builds Android et iOS).

[1.0.0]: https://github.com/mpaitier/cartodex/releases/tag/v1.0.0
