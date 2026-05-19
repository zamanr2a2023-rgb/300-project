# Firebase setup guide — Paned

Follow these steps to connect **Firebase Authentication (email/password)** and **Cloud Firestore** to the Paned Flutter app.

---

## 1. Create a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project**.
3. Name it (e.g. `Paned`).
4. Disable Google Analytics if you do not need it (optional).
5. Click **Create project**.

---

## 2. Add an Android app

1. In the project overview, click the **Android** icon.
2. **Android package name:** `com.paned.app.paned_app`  
   (must match `applicationId` in `android/app/build.gradle.kts`).
3. Register the app.
4. Download **`google-services.json`**.
5. Place it here:

   ```
   android/app/google-services.json
   ```

---

## 3. Add an iOS app (optional)

1. Click **Add app** → **iOS**.
2. **Bundle ID:** use the value from `ios/Runner.xcodeproj` (e.g. `com.paned.app.panedApp`).
3. Download **`GoogleService-Info.plist`**.
4. Place it in:

   ```
   ios/Runner/GoogleService-Info.plist
   ```

5. Open `ios/Runner.xcworkspace` in Xcode and confirm the plist is included in the **Runner** target.

---

## 4. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Ensure `~/.pub-cache/bin` (or `%LOCALAPPDATA%\Pub\Cache\bin` on Windows) is on your `PATH`.

---

## 5. Configure Firebase for Flutter

From the project root:

```bash
cd "d:\bluegiraffedart $300\paned_flutter"
flutterfire configure
```

- Select your Firebase project.
- Select platforms: **Android** (and **iOS** if you use it).
- This generates **`lib/firebase_options.dart`** with real API keys (replaces the placeholder).

Then:

```bash
flutter pub get
```

---

## 6. Gradle changes (Android)

Already applied in this repo:

**`android/settings.gradle.kts`** — Google Services plugin:

```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

**`android/app/build.gradle.kts`** — apply plugin:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

You still must add **`android/app/google-services.json`** from the console.

---

## 7. `main.dart`

Already initializes Firebase before `runApp`:

```dart
WidgetsFlutterBinding.ensureInitialized();
await initializeFirebase();
runApp(const ProviderScope(child: PanedApp()));
```

---

## 8. Enable Email/Password authentication

1. Firebase Console → **Build** → **Authentication**.
2. **Sign-in method** tab.
3. Enable **Email/Password**.
4. Save.

---

## 9. Create Firestore database

1. Firebase Console → **Build** → **Firestore Database**.
2. **Create database**.
3. Start in **test mode** for quick local testing, then deploy rules from step 10.
4. Choose a region close to your users (e.g. `europe-west2`).

---

## 10. Firestore security rules

Copy `firestore.rules` from this project into the Firebase Console → **Firestore** → **Rules**, or deploy with the Firebase CLI:

```text
users/{uid}           — profile + aggregate counts
users/{uid}/progress/{wordId}  — per-word swipe status
```

Recommended rules (also in `firestore.rules`):

- Authenticated users can **only** read/write their own `users/{uid}` document and `progress` subcollection.

Publish rules after testing.

---

## 11. Test the app

1. **Hot restart** or `flutter run` on a device/emulator with Google Play services (Android).
2. Complete onboarding if shown.
3. **Sign up** — new account → should land on **Home**.
4. **Log out** — Profile → **Log out** → should return to **Login**.
5. **Log in** — same account → Home.
6. Open **Core Welsh Words**, swipe a few cards.
7. In Firestore Console, verify:
   - `users/{your-uid}` exists with counts / `weekActivity`.
   - `users/{your-uid}/progress/{wordId}` documents with `status`, `deckId`, `reviewCount`.
8. Log out, sign in as another user — progress should **not** match the first account.

---

## Troubleshooting

| Issue | Fix |
|--------|-----|
| App crashes on launch | Run `flutterfire configure`; ensure `google-services.json` is present. |
| `operation-not-allowed` | Enable Email/Password in Authentication. |
| Permission denied on Firestore | Deploy `firestore.rules`; user must be signed in. |
| Progress not saving | Check internet; confirm UID in Firestore path matches Auth user. |

---

## Changed files (reference)

See the implementation summary in the project chat or README for the full list of Dart files added/updated for Auth and Firestore.
