# MacroTrack Frontend

Flutter app for tracking daily calorie and macronutrient intake. Connects to a Spring Boot backend with JWT authentication.

## File Structure

```
lib/
├── main.dart                     # App entry point + SplashGate (token restore, connection check)
├── theme/
│   └── app_theme.dart            # Dark color scheme + all Material widget themes
├── models/
│   ├── user.dart                 # AppUser data class
│   └── daily_summary.dart        # DailySummary, MealGroup, FoodItem with JSON serialization
├── services/
│   ├── api_service.dart          # HTTP client — all backend calls with JWT Bearer auth
│   └── local_storage_service.dart # SharedPreferences — persists token, user, daily intake cache
└── pages/
    ├── login_page.dart           # Email/password login → POST /api/auth/login
    ├── signup_page.dart          # Name/email/password signup → POST /api/auth/signup
    └── home_page.dart            # MyFitnessPal-style diary: calorie ring, macros, meal list
```

### Key Design Decisions

- **No state management library** — simple `setState` keeps dependencies minimal. Swap in Riverpod/Bloc later when needed.
- **Local caching** — `SharedPreferences` stores the JWT token (for auto-login) and the current day's `DailySummary` (for offline viewing).
- **Connection indicator** — a green/red dot in the app bar lights up based on `GET /api/health`.
- **Date navigation** — left/right arrows cycle days; "Today", "Yesterday", "Tomorrow" labels for nearby dates.
- **Calorie ring** — custom `CustomPainter` draws an arc proportional to consumed/goal.

## Setup

1. **Update the API URL** in `lib/services/api_service.dart`:

   | Environment | `_baseUrl` |
   |---|---|
   | Android emulator | `http://10.0.2.2:8080/api` |
   | iOS simulator | `http://localhost:8080/api` |
   | Windows/Web | `http://localhost:8080/api` |
   | Real device | `http://<YOUR_LAN_IP>:8080/api` |

2. **Run the backend** (Spring Boot, see `MacroTrack-Backend/`).

3. **Run the app**:
   ```
   flutter pub get
   flutter run
   ```

## Remaining Work

### 🔧 Backend
- [ ] **Implement forgot password endpoint** — `POST /api/auth/forgot-password`
- [ ] **Add email format validation** on signup
- [ ] **Add password strength validation** (min length)
- [ ] **Add refresh token flow** — short-lived access + long-lived refresh
- [ ] **Store per-macro goals on User** — `daily_carbs_goal`, `daily_protein_goal`, `daily_fat_goal`
- [ ] **Create profile endpoint** — `PUT /api/user/profile`
- [ ] **Wire OpenFoodFacts search** into meal creation flow
- [ ] **Better error DTOs** with field-level validation messages

### 📱 Frontend — Core Features
- [ ] **Wire up meal + buttons** — food search dialog / add-food page
- [ ] **Food search page** — connect to `GET /api/food/search?q=`
- [ ] **Barcode scanning** — add `mobile_scanner`, hit `GET /api/food/product/{barcode}/details`
- [ ] **Implement Search, Progress, More tabs** — currently stubs
- [ ] **Progress page** — weekly/monthly calorie/macro charts
- [ ] **Settings page** — profile edit, calorie goal, logout

### 🎨 Frontend — Polish
- [ ] **Form validation** on login/signup (empty fields, email format, passwords match)
- [ ] **Loading skeletons** instead of spinner
- [ ] **Pull-to-refresh** with last-updated timestamp
- [ ] **Handle 401 token expiry** — redirect to login
- [ ] **Onboarding flow** for first-time users (set goals)
- [ ] **Error + empty states** with retry buttons
- [ ] **Animate calorie ring** — smooth fill transition
- [ ] **Haptic feedback** on interactions

### 📦 Infrastructure
- [ ] **Deploy backend** — PostgreSQL + JAR (Docker or cloud)
- [ ] **CI/CD** — GitHub Actions: backend build + Flutter analyze/test
- [ ] **Environment config** — `--dart-define=BASE_URL=` for dev/staging/prod
- [ ] **Crash reporting** — Sentry or Firebase Crashlytics
- [ ] **Tests** — JUnit (backend), widget/unit tests (Flutter)

### 🧪 Testing
- [ ] **Full auth flow** — signup → login → token persist → auto-login → logout
- [ ] **Daily summary** — add meals, verify ring + macros + meal list
- [ ] **Date navigation** — prev/next day loads correct data
- [ ] **Offline mode** — cached summary shows without network
- [ ] **Connection indicator** — green dot when backend up, red when down
