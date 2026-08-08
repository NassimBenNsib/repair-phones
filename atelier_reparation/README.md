# Atelier Réparation

Application de gestion pour atelier de réparation, construite avec **Flutter**.
Un seul code source pour **Windows, macOS, Linux, Android, iOS et le Web**.

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal `stable`, ≥ 3.44)
- Selon la cible :
  - **Android** : Android Studio + SDK Android
  - **iOS / macOS** : Xcode (macOS uniquement)
  - **Windows** : Visual Studio avec la charge « Desktop development with C++ »
  - **Linux** : `clang`, `cmake`, `ninja-build`, `libgtk-3-dev`
  - **Web** : aucun outil supplémentaire

Vérifier l'environnement :

```bash
flutter doctor
```

## Démarrer

```bash
flutter pub get

# Lancer sur la plateforme de votre choix
flutter run -d windows
flutter run -d chrome
flutter run -d macos
flutter run -d linux
flutter run            # appareil/émulateur mobile connecté
```

## Compiler (release)

```bash
flutter build windows
flutter build macos
flutter build linux
flutter build apk           # Android
flutter build ipa           # iOS (macOS requis)
flutter build web
```

## Architecture

Structure **feature-first**, découplée et testable :

```text
lib/
├── main.dart                     # Point d'entrée (bootstrap + ProviderScope)
├── app/
│   └── app.dart                  # MaterialApp.router + thème + localisation
├── core/                         # Fondations transverses
│   ├── constants/                # Constantes & espacements
│   ├── router/                   # Configuration go_router
│   └── theme/                    # Thème Material 3 (clair / sombre)
├── shared/
│   └── widgets/                  # Widgets réutilisables (ex. coquille de nav.)
└── features/                     # Une fonctionnalité = un dossier
    ├── dashboard/presentation/   # Tableau de bord
    ├── repairs/presentation/     # Réparations
    ├── clients/presentation/     # Clients
    └── settings/presentation/    # Paramètres
```

Chaque fonctionnalité peut être étendue avec ses propres sous-couches
(`data/`, `domain/`, `presentation/`) au fil de son évolution.

## Stack technique

| Besoin               | Package                          |
| -------------------- | -------------------------------- |
| Navigation           | `go_router`                      |
| Gestion d'état       | `flutter_riverpod`               |
| Internationalisation | `intl` + `flutter_localizations` |
| Qualité de code      | `flutter_lints`                  |

## Tests

```bash
flutter test
flutter analyze
```
