import 'package:flutter/material.dart';
import 'package:mars_fx/logic/settings_manager.dart';
import 'package:mars_fx/pages/about_screen.dart';
import 'package:mars_fx/pages/cheat_sheet_screen.dart';
import 'package:mars_fx/services/service_locator.dart';
import 'package:mars_fx/theme/theme_constants.dart';
import 'package:mars_fx/theme/theme_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsManager>();
    final themeManager = getIt<ThemeManager>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 50, 0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeManager.themeModeNotifier,
              builder: (context, mode, _) => _NavRow(
                label: 'Appearance',
                trailing: mode == ThemeMode.dark ? 'Dark' : 'Light',
                onTap: themeManager.toggleTheme,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.showLongNameNotifier,
              builder: (context, showLongName, _) => _NavRow(
                label: 'Currency names',
                description: 'EUR  →  Euro',
                trailing: showLongName ? 'Long' : 'Short',
                onTap: () => settings.setShowLongName(!showLongName),
              ),
            ),
            _NavRow(
              label: 'Cheat sheet',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheatSheetScreen()),
              ),
            ),
            _NavRow(
              label: 'About',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final String? description;
  final String? trailing;
  final VoidCallback onTap;

  const _NavRow({
    required this.label,
    required this.onTap,
    this.description,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 50, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w200,
                        color: primary,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: COLOR_SECONDARY,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                child: Center(
                  child: trailing != null
                      ? Text(
                          trailing!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: COLOR_SECONDARY,
                          ),
                        )
                      : Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: primary.withValues(alpha: 0.3),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
