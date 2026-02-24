# Référence API — App mobile AI4BMI

Document de référence pour développer l’application mobile (e-commerce). À utiliser comme source de vérité pour l’intégration avec le backend Laravel.

---

## 1. Généralités

- **Base URL** : `https://ai4bmi.cabinet-xaviertermeau.com/api` (prod) ou `http://localhost:8000/api` (local).
- **Authentification** : **Bearer token** (Laravel Sanctum). Toutes les routes sauf `POST /register` et `POST /login` exigent l’en-tête :
  ```http
  Authorization: Bearer {token}
  ```
- **Connexion obligatoire** : l’utilisateur doit être connecté avant d’accéder au catalogue, au panier et aux commandes. Pas de consultation anonyme.

### Format des réponses

**Succès**
```json
{
  "success": true,
  "message": "Texte court",
  "data": { ... }
}
```

**Liste paginée** : `data` contient un tableau + métadonnées :
```json
{
  "success": true,
  "message": "OK",
  "data": [
    { "id": 1, ... }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 42
  },
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": "..."
  }
}
```

**Erreur**
```json
{
  "success": false,
  "message": "Message d'erreur"
}
```
Codes HTTP : `400` (requête invalide), `401` (non authentifié), `403` (interdit), `404` (non trouvé), `422` (validation / métier).

---

## 2. Auth

### 2.1 Inscription (public)

**POST** `/register`

Body JSON :
```json
{
  "name": "Jean Dupont",
  "email": "jean@example.com",
  "password": "secret123",
  "password_confirmation": "secret123",
  "phone": "66123456",
  "address": "Cotonou, quartier ..."
}
```
- Requis : `name`, `email`, `password`, `password_confirmation`.
- Optionnel : `phone`, `address`.

Réponse **201** :
```json
{
  "success": true,
  "message": "Inscription réussie.",
  "data": {
    "token": "1|xxxx...",
    "token_type": "Bearer",
    "user": {
      "id": 1,
      "name": "Jean Dupont",
      "email": "jean@example.com",
      "role": "customer",
      "phone": "66123456",
      "address": "Cotonou...",
      "profile_photo_url": null
    }
  }
}
```
→ Stocker `data.token` et l’utiliser pour les requêtes suivantes. L’utilisateur est connecté immédiatement.

### 2.2 Connexion (public)

**POST** `/login`

Body JSON :
```json
{
  "email": "jean@example.com",
  "password": "secret123"
}
```

Réponse **200** : même structure que l’inscription (`data.token`, `data.user`).

### 2.3 Mot de passe oublié (public)

**POST** `/forgot-password`

Body JSON : `{ "email": "jean@example.com" }`. Envoie un email avec un lien de réinitialisation (token inclus). Pour la sécurité, la réponse est la même que l'email existe ou non. Réponse **200** : `success`, `message` ("Si un compte existe avec cet email, un lien de réinitialisation a été envoyé."), `data: null`. **422** : email invalide. Flux app : l'utilisateur ouvre le lien reçu par email ; l'app peut parser l'URL pour récupérer `token` et `email`, puis afficher un écran « Nouveau mot de passe » et appeler **POST** `/password/reset`.

### 2.4 Réinitialiser le mot de passe (public)

**POST** `/password/reset`

Body JSON : `email`, `token` (reçu par email dans le lien), `password`, `password_confirmation`. Mêmes règles mot de passe que l'inscription. Réponse **200** : "Mot de passe réinitialisé. Vous pouvez vous connecter." Réponse **422** : token invalide/expiré ou validation.

### 2.5 Déconnexion (auth)

**POST** `/logout`

Headers : `Authorization: Bearer {token}`. Pas de body.

Réponse **200** : `{ "success": true, "message": "..." }`. Invalider le token côté app.

### 2.6 Utilisateur courant (auth)

**GET** `/user`

Réponse **200** :
```json
{
  "success": true,
  "message": "OK",
  "data": {
    "id": 1,
    "name": "Jean Dupont",
    "email": "jean@example.com",
    "role": "customer",
    "phone": "66123456",
    "address": "...",
    "profile_photo_url": "https://.../storage/profile-photos/xxx.jpg"
  }
}
```

### 2.7 Modifier le profil (auth)

**PATCH** `/user`

Body JSON (tous optionnels) :
```json
{
  "name": "Nouveau nom",
  "email": "nouveau@example.com",
  "phone": "66987654",
  "address": "Nouvelle adresse"
}
```
Réponse **200** : `data` = objet user mis à jour (même forme que GET `/user`).

### 2.8 Photo de profil (auth)

**POST** `/user/photo`

Content-Type : `multipart/form-data`, champ **`photo`** (fichier image, max 2 Mo).

Réponse **200** : `data` = user avec `profile_photo_url` mis à jour.

### 2.9 Changer le mot de passe (auth)

**PATCH** `/user/password`

Headers : `Authorization: Bearer {token}`.

Body JSON :
```json
{
  "current_password": "ancien_mot_de_passe",
  "password": "nouveau_mot_de_passe",
  "password_confirmation": "nouveau_mot_de_passe"
}
```

Réponse **200** :
```json
{
  "success": true,
  "message": "Mot de passe mis à jour.",
  "data": null
}
```
Réponse **401** : non authentifié. Réponse **422** : mot de passe actuel incorrect ou validation.

---

## 3. Catalogue (auth)

### 3.1 Liste des catégories

**GET** `/categories?per_page=20&with_products=1`

- `per_page` : optionnel, max 50 (défaut 20).
- `with_products` : optionnel, `1` pour inclure les produits dans chaque catégorie.

Réponse **200** : liste paginée. Chaque élément :
```json
{
  "id": 1,
  "name": "Pièces moteur",
  "description": "...",
  "products_count": 12,
  "products": [ ... ]
}
```
Si `with_products` n’est pas envoyé, `products` est absent et `products_count` peut être présent.

### 3.2 Détail d’une catégorie

**GET** `/categories/{id}`

Réponse **200** : un objet catégorie avec `products` (tableau de produits).

### 3.3 Liste des produits

**GET** `/products?category_id=1&search=clé&per_page=20`

- `category_id` : optionnel.
- `search` : optionnel (recherche dans nom et description).
- `per_page` : optionnel, max 50.

Réponse **200** : liste paginée. Chaque élément (Product) :
```json
{
  "id": 1,
  "name": "Filtre à huile",
  "description": "...",
  "price": 2500.50,
  "stock_quantity": 10,
  "in_stock": true,
  "image_url": "https://.../storage/...",
  "category": { "id": 1, "name": "...", "description": "..." },
  "category_id": 1
}
```

### 3.4 Détail d’un produit

**GET** `/products/{id}`

Réponse **200** : un objet produit (même structure que ci-dessus, avec `category` chargée).

---

## 4. Panier (auth)

### 4.1 Voir le panier

**GET** `/cart`

Réponse **200** :
```json
{
  "success": true,
  "message": "OK",
  "data": {
    "id": 1,
    "items_count": 3,
    "subtotal": 15000.00,
    "items": [
      {
        "id": 10,
        "product_id": 2,
        "quantity": 2,
        "unit_price": 5000,
        "subtotal": 10000,
        "product": { "id": 2, "name": "...", "price": 5000, ... }
      }
    ]
  }
}
```

### 4.2 Vider le panier

**DELETE** `/cart`

Réponse **200** : `data` = panier (souvent avec `items` vide).

### 4.3 Ajouter au panier

**POST** `/cart/items`

Body JSON :
```json
{
  "product_id": 2,
  "quantity": 1
}
```
Si le produit est déjà dans le panier, la quantité est augmentée. Vérification du stock ; **422** si stock insuffisant.

Réponse **200** : `data` = panier mis à jour (CartResource).

### 4.4 Modifier la quantité d’une ligne

**PATCH** `/cart/items/{cartItemId}`

Body JSON :
```json
{
  "quantity": 3
}
```
**422** si stock insuffisant.

### 4.5 Supprimer une ligne du panier

**DELETE** `/cart/items/{cartItemId}`

Réponse **200** : panier mis à jour.

---

## 5. Commandes (auth)

### 5.1 Liste des commandes

**GET** `/orders?status=pending&per_page=15`

- `status` : optionnel, `pending` | `paid` | `shipped` | `cancelled`.
- `per_page` : optionnel, max 50.

Réponse **200** : liste paginée. Chaque commande :
```json
{
  "id": 1,
  "total_amount": 25000.00,
  "status": "pending",
  "shipping_address": "Cotonou...",
  "shipping_phone": "66123456",
  "created_at": "2026-02-22T12:00:00.000000Z",
  "items": [
    {
      "id": 1,
      "product_id": 2,
      "quantity": 2,
      "price": 5000,
      "subtotal": 10000,
      "product": { "id": 2, "name": "...", ... }
    }
  ]
}
```

### 5.2 Détail d’une commande

**GET** `/orders/{id}`

Réponse **200** : un objet commande (même structure). **403** si la commande n’appartient pas à l’utilisateur.

### 5.3 Créer une commande

**POST** `/orders`

Body JSON (optionnel) :
```json
{
  "shipping_address": "Adresse de livraison",
  "shipping_phone": "66987654"
}
```
Si absent, l’adresse et le téléphone du **profil** utilisateur sont utilisés.

- Crée la commande à partir du **panier** actuel.
- Vérification du stock ; **422** si panier vide ou stock insuffisant.
- Le panier est vidé, le stock décrémenté. Statut initial : **`pending`**.

Réponse **201** : `data` = commande créée (OrderResource avec `items`).

### 5.4 Initier le paiement FedaPay

**POST** `/orders/{id}/payment`

- Commande doit être en **pending** et appartenir à l’utilisateur.

Réponse **200** :
```json
{
  "success": true,
  "message": "Ouvrez payment_url dans un navigateur ou WebView pour payer.",
  "data": {
    "payment_url": "https://sandbox-process.fedapay.com/eyJ...",
    "token": "eyJ...",
    "transaction_id": "408671"
  }
}
```

**Flux côté app** :
1. Appeler cette route après création de la commande.
2. Ouvrir **`data.payment_url`** dans un **WebView** ou navigateur.
3. L’utilisateur paie (Mobile Money, etc.) sur la page FedaPay.
4. FedaPay redirige vers `{APP_URL}/api/orders/{id}/payment/callback?status=approved&id=...` (page HTML « Paiement réussi »).
5. La commande passe en **paid** via le **webhook** (côté serveur). L’app peut **sonder** `GET /api/orders/{id}` pour détecter `status === "paid"` ou fermer la WebView et rafraîchir l’écran commande.

### 5.5 Annuler une commande

**POST** `/orders/{id}/cancel`

- Autorisé uniquement si la commande est en **pending**. Le stock est recrédité.

Réponse **200** : `data` = commande avec `status: "cancelled"`. **422** si la commande n’est plus pending.

---

## 6. Callback paiement (navigateur / WebView)

**GET** `/orders/{order}/payment/callback?status=approved&id=408671`

- Appelé par **redirection** FedaPay après paiement. Pas d’auth.
- Réponse : **page HTML** (« Paiement réussi » ou statut). L’app peut fermer la WebView à ce moment et rafraîchir les données.

---

## 7. Récap des routes (à ne pas oublier)

| Méthode | Route | Auth | Rôle |
|--------|--------|------|------|
| POST | /register | Non | Inscription + token + user |
| POST | /login | Non | Connexion + token + user |
| POST | /forgot-password | Non | Mot de passe oublié (envoi email) |
| POST | /password/reset | Non | Réinitialiser le mot de passe (token + email) |
| POST | /logout | Oui | Déconnexion |
| GET | /user | Oui | Profil |
| PATCH | /user | Oui | Modifier profil |
| POST | /user/photo | Oui | Photo de profil (multipart) |
| PATCH | /user/password | Oui | Changer le mot de passe (current_password + password) |
| GET | /categories | Oui | Liste catégories (pag.) |
| GET | /categories/{id} | Oui | Détail catégorie |
| GET | /products | Oui | Liste produits (pag., category_id, search) |
| GET | /products/{id} | Oui | Détail produit |
| GET | /cart | Oui | Panier |
| DELETE | /cart | Oui | Vider panier |
| POST | /cart/items | Oui | Ajouter (product_id, quantity) |
| PATCH | /cart/items/{id} | Oui | Modifier quantité |
| DELETE | /cart/items/{id} | Oui | Supprimer ligne |
| GET | /orders | Oui | Liste commandes (pag., status) |
| GET | /orders/{id} | Oui | Détail commande |
| POST | /orders | Oui | Créer commande (shipping_* optionnel) |
| POST | /orders/{id}/payment | Oui | Obtenir payment_url FedaPay |
| POST | /orders/{id}/cancel | Oui | Annuler (si pending) |
| GET | /orders/{id}/payment/callback | Non | Redirection FedaPay (HTML) |

---

## 8. Flux utilisateur recommandé (app mobile)

1. **Écran d’accueil** : si pas de token → Inscription / Connexion. Sinon → Accueil (catalogue ou profil).
2. **Profil** : GET /user ; édition avec PATCH /user ; photo avec POST /user/photo ; changement de mot de passe avec PATCH /user/password (current_password, password, password_confirmation).
3. **Catalogue** : GET /categories puis GET /products (avec category_id ou search). Détail produit : GET /products/{id}.
4. **Panier** : GET /cart ; ajout POST /cart/items ; modification PATCH /cart/items/{id} ; suppression DELETE /cart/items/{id}.
5. **Checkout** :  
   - POST /orders (avec ou sans shipping_address, shipping_phone).  
   - Puis POST /orders/{id}/payment → ouvrir `data.payment_url` en WebView.  
   - À la redirection callback (ou fermeture WebView), appeler GET /orders/{id} jusqu’à `status === "paid"` (ou timeout).
6. **Mes commandes** : GET /orders ; détail GET /orders/{id}. Annulation possible avec POST /orders/{id}/cancel si status === "pending".

---

## 9. Détails techniques utiles

- **Pagination** : toutes les listes (categories, products, orders) sont paginées. Utiliser `meta.current_page`, `meta.last_page`, `meta.per_page`, `meta.total` et `links.next` / `links.prev` pour la pagination côté app.
- **Images** : `profile_photo_url` (user) et `image_url` (product) sont des URL absolues. Les afficher avec un composant Image.
- **Statuts commande** : `pending` (créée, en attente de paiement), `paid` (payée), `shipped` (expédiée), `cancelled` (annulée).
- **Stock** : `in_stock` (booléen) et `stock_quantity` sur les produits. Ne pas autoriser d’ajouter au panier au-delà du stock ; le backend renvoie 422 si dépassement.

Ce document reflète l’API au moment de sa rédaction. En cas de doute, se référer au code (routes `routes/api.php`, contrôleurs `app/Http/Controllers/Api/`, resources `app/Http/Resources/`).
