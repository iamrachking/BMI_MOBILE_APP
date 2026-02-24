# BMI SHOP

**Boutique mobile pièces auto & moto** — Parcours complet : catalogue, panier, commande et paiement Mobile Money (FedaPay).

## Aperçu

BMI SHOP est l’application mobile du projet **GL Hack 2026** (Groupe 5 E-Commerce). Elle permet de parcourir le catalogue, gérer le panier, passer commande et payer via FedaPay (Mobile Money) sans quitter l’app.

- **Backend** : API Laravel — [Documentation](https://ai4bmi.cabinet-xaviertermeau.com/api-docs)


## Captures d’écran

**Ligne 1 —** Splash · Onboarding · Connexion · Accueil

| | | | |
|:---:|:---:|:---:|:---:|
| ![Splash](screenshots/splash.jpg) | ![Onboarding](screenshots/onboarding.jpg) | ![Connexion](screenshots/login.jpg) | ![Accueil](screenshots/home.jpg) |

**Ligne 2 —** Catalogue · Détail produit · Panier · Commandes · Profil

| | | | | |
|:---:|:---:|:---:|:---:|:---:|
| ![Catalogue](screenshots/catalogue.jpg) | ![Détail produit](screenshots/product_detail.jpg) | ![Panier](screenshots/cart.jpg) | ![Commandes](screenshots/order_list.jpg) | ![Profil](screenshots/profil.jpg) |

---

## Démarrage rapide

```bash
git clone https://github.com/IFRI-Hackaton-L3-2025-2026/GL-Hack2026-Groupe_5_E-Commerce.git
cd GL-Hack2026-Groupe_5_E-Commerce
flutter pub get
flutter run
```

- **Flutter** : SDK ^3.9.2  
- **Émulateur** : Android Studio ou Xcode ou telephone 

Pour régénérer l’icône de l’app :

```bash
dart run flutter_launcher_icons
```

## Stack

- **Flutter** + **GetX** (état & navigation)
- **Dio** (API, Bearer token)
- **webview_flutter** (paiement FedaPay)
- **get_storage** (token, onboarding)


## Configuration API

- **Production** : `https://ai4bmi.cabinet-xaviertermeau.com/api`
- **Local** : éditer `lib/config/api_config.dart` (ex. `http://10.0.2.2:8000/api` pour Android).


## Licence

Projet **GL Hack 2026** — Groupe 5 E-Commerce.
