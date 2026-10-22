# CLAUDE.md

Mars Currency — a currency converter where **every currency is both input and
output**: tap any row, type, and all other rows update. There is no "base
currency" the user ever sees.

This is the **reference implementation** for Mars conventions (`../DESIGN.md`):
when in doubt how another app should structure DI, state, theme or constants,
look here.

## Commands

```bash
flutter run
flutter test
flutter analyze
./install_debug.sh     # "Mars Currency Debug", com.catchingclouds.marsfx.debug
./install_release.sh   # "Mars Currency",       com.catchingclouds.marsfx
```

## Things that aren't obvious from the code

- **Store id ≠ Dart package.** The Play applicationId is `com.catchingclouds.marsfx`
  (no underscore); the Dart package is `mars_fx`. The id is permanent on Play —
  never derive store or deep links from the Dart name.
- Rates come from ExchangeRate-API with **EUR as base**; EUR is implicitly 1.0
  and conversion is `amount / rates[from] * rates[to]`.
- Offline first: cached rates load immediately, refresh runs in the background.
- `CurrencyData` is a deliberately curated subset (60 currencies), not
  everything the API offers.
- Registration order in the service locator matters: `LocalStorageService`
  (async) first.

## Interactions

Tap a row = make it the input · swipe left = remove (no confirmation) ·
long-press = move to top · "+ Add Currency" = search screen.
