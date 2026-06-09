import 'package:flutter/material.dart';
import 'package:mars_fx/theme/theme_constants.dart';

/// Manages dark/light theme, following Mars Launcher pattern.
class ThemeManager {
  late final ValueNotifier<ThemeMode> themeModeNotifier;

  ThemeManager() {
    // Follow system theme
    themeModeNotifier = ValueNotifier(ThemeMode.system);
  }

  ThemeData get lightTheme => buildLightTheme();
  ThemeData get darkTheme => buildDarkTheme();
}
