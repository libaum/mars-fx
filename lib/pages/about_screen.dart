import 'package:flutter/material.dart';
import 'package:mars_fx/pages/widgets/double_tap_theme_toggle.dart';
import 'package:mars_fx/theme/theme_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DoubleTapThemeToggle(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mars FX',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: primary),
                ),
                const SizedBox(height: 32),
                Text(
                  'A currency converter I built because the ones on the store were either ugly, bloated, or both.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: primary, height: 1.7),
                ),
                const SizedBox(height: 24),
                Text(
                  'Every currency is both input and output.\nTap any row. Type. Everything updates.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: primary, height: 1.7),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No ads. No tracking. No accounts.\nJust an app that does one thing well.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: COLOR_SECONDARY, height: 1.7),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Rates via Frankfurter API.\nPart of the Mars product family.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: COLOR_SECONDARY, height: 1.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
