# Mars Currency

Ultra-minimal currency converter for Android.

Every currency is both an input and an output. Tap any row, type a value, and all other currencies update instantly.

## Features

- **Bidirectional conversion** — no "from" or "to", any currency is editable
- **Offline-first** — cached rates load instantly, refreshes in background
- **Add / remove currencies** — search by code or name, swipe to delete
- **Long-press to reorder** — moves a currency to the top
- **Light & dark mode** — follows system theme
- **30 currencies** via [Frankfurter API](https://frankfurter.app) (no API key required)

## Install

```bash
# Debug (installs as "Mars Currency Debug")
./install_debug.sh

# Release (installs as "Mars Currency")
./install_release.sh
```

## Tech Stack

- Flutter / Dart
- GetIt (dependency injection)
- SharedPreferences (local persistence)
- Frankfurter API (exchange rates)

## Design

Part of the [Mars](https://github.com/nicholasgasior/mars_launcher) product family. Pure black & white, Outfit font, no visual clutter.

## License

MIT
