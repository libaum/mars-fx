import 'package:flutter/material.dart';
import 'package:mars_fx/pages/main_screen.dart';
import 'package:mars_fx/services/service_locator.dart';
import 'package:mars_fx/theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MarsFX());
}

class MarsFX extends StatelessWidget {
  const MarsFX({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = getIt<ThemeManager>();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mars FX',
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}

