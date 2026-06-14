# MacroTrack

Application Flutter de suivi nutritionnel (calories et macronutriments). Se connecte à un backend Spring Boot avec authentification JWT.

## Architecture

```
lib/
├── main.dart                     # Point d'entrée + SplashGate (restauration token, vérification connexion)
├── theme/
│   └── app_theme.dart            # Thème sombre/clair + personnalisation des widgets Material
├── models/
│   ├── product.dart              # Produit alimentaire (parse OpenFoodFacts + Spring Boot)
│   ├── user.dart                 # AppUser avec ratios de macros
│   └── daily_summary.dart        # DailySummary, MealGroup, FoodItem
├── services/
│   ├── api_service.dart          # Client HTTP — tous les appels backend avec JWT Bearer
│   └── local_storage_service.dart # SharedPreferences — token, user, cache journalier, thème
├── pages/
│   ├── login_page.dart           # Connexion email/mot de passe → POST /api/auth/login
│   ├── signup_page.dart          # Inscription → POST /api/auth/signup
│   ├── home_page.dart            # Navigation par onglets (Journal, Recherche, Progrès, Plus)
│   ├── search_page.dart          # Recherche d'aliments + scan code-barres
│   ├── barcode_scanner_page.dart # Scanner caméra avec mobile_scanner
│   ├── profile_page.dart         # Édition du profil (nom, calories, ratios P/L/G)
│   ├── progress_page.dart        # Graphiques hebdomadaires (barres, courbes, camembert)
│   ├── settings_page.dart        # Mode sombre/clair
│   ├── more_page.dart            # Menu : Profil, Paramètres, À propos, Déconnexion
│   └── about_page.dart           # Informations de l'application
└── widgets/
    ├── diary_page.dart           # Journal alimentaire (anneau calorique, macros, repas)
    ├── calorie_ring_card.dart    # Anneau de progression CustomPainter
    ├── macro_breakdown_card.dart # Barres de progression des macronutriments
    ├── meal_card.dart            # Carte de repas (petit-déj, déjeuner, dîner, snacks)
    ├── food_card.dart            # Carte de résultat de recherche
    └── indicator.dart            # Indicateur de légende pour les graphiques
```

## Choix techniques

- **Pas de bibliothèque d'état** — `setState` simple + champs statiques dans `ApiService` + `ValueNotifier` pour le thème
- **Cache local** — `SharedPreferences` stocke le JWT (auto-connexion) et le résumé du jour (consultation hors-ligne)
- **Indicateur de connexion** — point vert/rouge dans la barre d'application (GET /api/health)
- **Navigation datée** — flèches gauche/droite pour changer de jour ; libellés "Aujourd'hui", "Hier", "Demain"
- **Anneau calorique** — `CustomPainter` dessine un arc proportionnel au rapport consommé/objectif
- **Thème dynamique** — `ValueNotifier<ThemeMode>` + `ListenableBuilder`, pas de Provider

## Prérequis

- Flutter SDK (^3.11)
- Backend Spring Boot 4.0.5 + PostgreSQL 16 (voir `../MacroTrack-Backend`)

## Installation

1. **Configurer l'URL de l'API** dans `lib/services/api_service.dart` :

   | Environnement | `_baseUrl` |
   |---|---|
   | Émulateur Android | `http://10.0.2.2:8080/api` |
   | Simulateur iOS | `http://localhost:8080/api` |
   | Windows/Web | `http://localhost:8080/api` |
   | Appareil réel | `http://<VOTRE_IP_LAN>:8080/api` |

2. **Lancer le backend** (Spring Boot, voir `../MacroTrack-Backend`).

3. **Lancer l'application** :
   ```
   flutter pub get
   flutter run
   ```

## Fonctionnalités

- Authentification (inscription, connexion, JWT persistant)
- Profil utilisateur (nom, objectif calorique, ratios protéines/lipides/glucides)
- Recherche d'aliments par texte ou scan de code-barres (OpenFoodFacts)
- Journal alimentaire (4 repas, navigation jour par jour)
- Graphiques hebdomadaires (barres, courbes, camembert avec fl_chart)
- Thème sombre/clair

## Build

```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build windows      # Windows
flutter build web          # Web
```
