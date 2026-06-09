import 'package:flutter/material.dart';
import 'package:mars_fx/pages/widgets/double_tap_theme_toggle.dart';
import 'package:mars_fx/theme/theme_constants.dart';

class CheatSheetScreen extends StatelessWidget {
  const CheatSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'Cheat Sheet',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: primary),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader('Gestures'),
                      const SizedBox(height: 20),
                      _GestureRow('Tap', 'Activate row for editing'),
                      _GestureRow('Double-tap', 'Toggle dark / light mode'),
                      _GestureRow('Long-press', 'Move row to top'),
                      _GestureRow('Swipe right', 'Copy amount'),
                      _GestureRow('Swipe left', 'Remove currency'),
                      _GestureRow('Long-press void', 'Open settings'),
                      const SizedBox(height: 40),
                      _SectionHeader('Add currencies'),
                      const SizedBox(height: 20),
                      _GestureRow('+ Add Currency', 'Opens currency search'),
                      const SizedBox(height: 40),
                    ],
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

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, letterSpacing: 1.4, color: COLOR_SECONDARY, fontWeight: FontWeight.w400),
    );
  }
}

class _GestureRow extends StatelessWidget {
  final String gesture;
  final String description;
  const _GestureRow(this.gesture, this.description);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              gesture,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: primary),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: COLOR_SECONDARY),
            ),
          ),
        ],
      ),
    );
  }
}
