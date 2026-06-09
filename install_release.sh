#!/bin/bash
set -e

echo "Building Mars FX (Release)..."
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK not found at $APK_PATH"
    exit 1
fi

echo "Installing Mars FX..."
adb install -r "$APK_PATH"

echo "Done. Mars FX installed."
