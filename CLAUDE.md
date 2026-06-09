# CLAUDE.md

This file provides guidance when working with code in this repository.

## Project Overview

Mars FX is a minimal Flutter Android currency converter. Every currency is both an input and an output — tap any row, type a value, and all other visible currencies update instantly. Part of the Mars product family.

## Common Commands

```bash
# Run app
flutter run

# Run tests
flutter test

# Lint / static analysis
flutter analyze

# Build + install debug APK (app name: "Mars FX Debug", package: com.catchingclouds.mars_fx.debug)
./install_debug.sh

# Build + install release APK (app name: "Mars FX", package: com.catchingclouds.mars_fx)
./install_release.sh
```

## Architecture

### Dependency Injection

All global state lives in singleton classes registered via `GetIt` in `lib/services/service_locator.dart`. Access anywhere: `getIt<CurrencyListManager>()`. Services are initialized once in `main()` before `runApp`. Registration order matters — `LocalStorageService` (async) must be first.

### State Management

Managers expose state via `ValueNotifier`. UI widgets subscribe with `ValueListenableBuilder`. No Bloc/Provider/Riverpod — pure Flutter primitives, matching Mars Launcher.

### Key Classes

| Class | Responsibility |
|---|---|
| `ExchangeRateService` | HTTP client for Frankfurter API (`api.frankfurter.app/latest`) |
| `LocalStorageService` | SharedPreferences wrapper for cached rates, visible currencies, timestamps |
| `ExchangeRateRepository` | Coordinates API ↔ cache; offline-first (cache loads first, refresh in background) |
| `CurrencyConverter` | Pure stateless conversion logic; all rates EUR-based internally |
| `CurrencyData` | Static map of ISO code → full currency name (30 currencies) |
| `CurrencyListManager` | Manages visible list, active input currency, computed amounts, reordering |
| `ThemeManager` | Light/dark mode following system theme |

### Conversion Model

All exchange rates from Frankfurter API are EUR-based. EUR has an implicit rate of 1.0. Conversion formula: `amount / rates[from] * rates[to]`. The user never sees a "base currency" — any row can be tapped to become the input.

### Persistence

All user data stored locally via SharedPreferences:
- Visible currency list + order
- Cached exchange rates (JSON)
- Last update timestamp

No backend, no remote sync.

## Project Structure

```
lib/
├── data/
│   ├── exchange_rate_service.dart    # Frankfurter API client
│   ├── exchange_rate_repository.dart # Offline-first cache coordinator
│   └── local_storage_service.dart    # SharedPreferences wrapper
├── domain/
│   ├── currency_converter.dart       # Pure conversion logic
│   └── currency_data.dart            # Currency metadata
├── logic/
│   └── currency_list_manager.dart    # Core state manager
├── pages/
│   ├── main_screen.dart              # Single-screen layout
│   ├── currency_search_screen.dart   # Add currency search
│   └── widgets/
│       ├── currency_row.dart         # Individual currency row
│       └── status_bar.dart           # Update status display
├── services/
│   └── service_locator.dart          # GetIt registration
├── theme/
│   ├── theme_constants.dart          # Colors, text styles, theme builders
│   └── theme_manager.dart            # System theme management
└── main.dart                         # Entry point
```

## Key Interactions

- **Tap** a currency row → make it active (editable input)
- **Type** a value → all other currencies recalculate instantly
- **Swipe left** on a row → delete currency (no confirmation)
- **Long-press** a row → move to top of list
- **Tap "+ Add Currency"** → opens search screen

## Design Conventions

- **Naming**: Constants use `SCREAMING_CASE` (matches Mars Launcher)
- **Font**: Outfit with tabular figures for stable number alignment
- **Colors**: Pure black/white only; `COLOR_SECONDARY` (gray) for secondary text
- **Package name**: `com.catchingclouds.mars_fx` (debug: `.debug` suffix)

## Build Variants

| Variant | Package Name | App Name |
|---------|-------------|----------|
| Debug | `com.catchingclouds.mars_fx.debug` | Mars FX Debug |
| Release | `com.catchingclouds.mars_fx` | Mars FX |

Both can be installed simultaneously on the same device.
