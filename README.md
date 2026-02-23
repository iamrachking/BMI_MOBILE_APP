# BMI — Application mobile e-commerce

Application E-commerce (pièces auto & moto) pour le projet GL Hack 2026.  
Backend : API Laravel (voir `https://ai4bmi.cabinet-xaviertermeau.com/api-docs`).

---

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK ^3.9.2)
- Android Studio / Xcode pour émulateur ou appareil


## Installation

```bash
# Cloner le dépôt 
https://github.com/IFRI-Hackaton-L3-2025-2026/GL-Hack2026-Groupe_5_E-Commerce.git
# cd GL-Hack2026-Groupe_5_E-Commerce

# Dépendances
flutter pub get
```

## Lancer l'app

```bash
flutter run
```

Pour régénérer les icônes de l'app (logo) :

```bash
dart run flutter_launcher_icons
```

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée, thème, routes
├── config/                   # Configuration API (base URL)
├── core/                     # Thème, réseau (Dio), stockage (token, onboarding)
├── data/                     # Modèles et services API (auth, produits, panier, commandes)
├── routes/                   # Routes GetX (app_routes, app_pages)
├── features/
│   ├── splash/               # Écran de démarrage
│   ├── onboarding/           # 3 pages d'introduction
│   ├── auth/                 # Connexion, inscription
│   ├── home/                 # Accueil (catalogue, panier, commandes, profil)
│   ├── catalog/              # Catalogue et détail produit
│   ├── cart/                 # Panier
│   ├── orders/               # Commandes
│   └── profile/              # Profil utilisateur
```

- **État & navigation** : GetX  
- **HTTP** : Dio (Bearer token automatique)  
- **Stockage local** : get_storage (token, onboarding vu)


## Couleurs de l'app

- **Primaire** : `#2e4053`
- **Fond** : `#f9fafc`

Définies dans `lib/core/theme/app_theme.dart`.


## Assets

À placer dans `assets/images/` :

- `onboarding_1.png`, `onboarding_2.png`, `onboarding_3.png` — onboarding
- `logo.png` — splash
- `logo_icon.png` — icône de l'app (launcher)
- `apple.png`, `google.png`, `facebook.png` — boutons de connexion sociale


## API

- **Prod** : `https://ai4bmi.cabinet-xaviertermeau.com/api`
- **Local** : modifier `lib/config/api_config.dart` (ex. `http://10.0.2.2:8000/api` pour Android)



## Licence

Projet GL Hack 2026 — Groupe 5 E-Commerce.
