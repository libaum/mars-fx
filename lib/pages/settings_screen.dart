import 'package:flutter/material.dart';
import 'package:mars_fx/logic/settings_manager.dart';
import 'package:mars_fx/pages/about_screen.dart';
import 'package:mars_fx/pages/cheat_sheet_screen.dart';
import 'package:mars_fx/pages/widgets/double_tap_theme_toggle.dart';
import 'package:mars_fx/services/service_locator.dart';
import 'package:mars_fx/theme/theme_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsManager>();
    final primary = Theme.of(context).colorScheme.primary;

    return DoubleTapThemeToggle(
      child: Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _ToggleRow(
              label: 'Long currency names',
              description: 'EUR  →  Euro',
              notifier: settings.showLongNameNotifier,
              onChanged: settings.setShowLongName,
            ),
            _Divider(),
            _ToggleRow(
              label: 'Show base currency',
              description: 'EUR is the reference rate',
              notifier: settings.showBaseCurrencyNotifier,
              onChanged: settings.setShowBaseCurrency,
            ),
            _Divider(),
            _NavRow(
              label: 'Cheat Sheet',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheatSheetScreen()),
              ),
            ),
            _Divider(),
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
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String description;
  final ValueNotifier<bool> notifier;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.description,
    required this.notifier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: primary)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 13, color: COLOR_SECONDARY)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: primary)),
            ),
            Icon(Icons.chevron_right, size: 20, color: primary.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Divider(height: 1, thickness: 0.5, color: primary.withValues(alpha: 0.1), indent: 32, endIndent: 32);
  }
}
