# Captures brutes

Ce dossier contient les captures d'écran telles qu'elles sortent du téléphone. `tool/store_screenshots/generate.py` les met en forme et écrit le résultat dans `docs/screenshots/`.

Les noms attendus sont fixés dans `tool/store_screenshots/screens.json` :

| Fichier | Écran |
|---|---|
| `01_accueil.png` | Accueil, sur une série bien avancée, avec le bandeau de progression et quelques tuiles de sets |
| `02_set.png` | Détail d'un set où se mélangent cartes du principal, des secondaires et cartes manquantes |
| `03_filtres.png` | Panneau de filtres ouvert dans le détail d'un set |
| `04_comptes.png` | Écran des comptes, avec un principal et au moins deux secondaires |
| `05_stats.png` | Statistiques, avec la liste des boosters prioritaires visible |
| `06_cloud.png` | Écran de connexion ou de synchronisation |

Quelques conseils pour un rendu propre :

- capturer en mode clair (ou tout en mode sombre, mais pas un mélange) ;
- prendre toutes les captures sur le même téléphone, pour garder le même format ;
- nettoyer la barre d'état avant (batterie pleine, pas de notifications), ou activer le mode démo d'Android dans les options pour les développeurs ;
- éviter les noms de comptes ou les codes ami réels sur `04_comptes.png`.

S'il manque une capture, le script s'arrête sans rien générer et liste les fichiers absents.
