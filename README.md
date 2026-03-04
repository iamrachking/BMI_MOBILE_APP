# BMI SHOP

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/GetX-8B0000?style=for-the-badge&logo=getx&logoColor=white" alt="GetX" />
  <img src="https://img.shields.io/badge/Dio-00897B?style=for-the-badge" alt="Dio" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS" />
</p>

**Boutique mobile pièces auto & moto** — Catalogue, panier, commande et paiement Mobile Money (FedaPay) dans une seule app.

---

## Aperçu

BMI SHOP est une application mobile e-commerce qui permet de parcourir le catalogue, gérer le panier, passer commande et payer via **FedaPay** (Mobile Money) sans quitter l’app.

- **Backend** : API Laravel — [Documentation](https://ai4bmi.cabinet-xaviertermeau.com/api-docs)

---

## Captures d’écran

**Splash · Onboarding · Connexion · Accueil**

| | | | |
|:---:|:---:|:---:|:---:|
| ![Splash](screenshots/splash.jpg) | ![Onboarding](screenshots/onboarding.jpg) | ![Connexion](screenshots/login.jpg) | ![Accueil](screenshots/home.jpg) |

**Catalogue · Détail produit · Panier · Commandes · Profil**

| | | | | |
|:---:|:---:|:---:|:---:|:---:|
| ![Catalogue](screenshots/catalogue.jpg) | ![Détail produit](screenshots/product_detail.jpg) | ![Panier](screenshots/cart.jpg) | ![Commandes](screenshots/order_list.jpg) | ![Profil](screenshots/profil.jpg) |

---

## Démarrage rapide

```bash
git clone https://github.com/iamrachking/BMI_MOBILE_APP.git
cd BMI_MOBILE_APP
flutter pub get
flutter run
```

- **Flutter** : SDK ^3.9.2  
- **Émulateur** : Android Studio, Xcode ou appareil physique

Régénérer l’icône de l’app :

```bash
dart run flutter_launcher_icons
```

---

## Stack

- **Flutter** + **GetX** (état & navigation)
- **Dio** (API, Bearer token)
- **webview_flutter** (paiement FedaPay)
- **get_storage** (token, onboarding)

---

## Configuration API

- **Production** : `https://ai4bmi.cabinet-xaviertermeau.com/api`
- **Local** : éditer `lib/config/api_config.dart` (ex. `http://10.0.2.2:8000/api` pour Android).

---

## Licence

MIT
