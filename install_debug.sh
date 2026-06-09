#!/bin/bash
set -e

echo "Building Mars FX (Debug)..."
flutter build apk --debug

APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"

if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK not found at $APK_PATH"
    exit 1
fi

echo "Installing Mars FX Debug..."
adb install -r "$APK_PATH"

echo "Done. Mars FX Debug installed."
