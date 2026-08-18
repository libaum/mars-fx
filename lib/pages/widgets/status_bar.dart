import 'package:flutter/material.dart';
import 'package:mars_fx/data/exchange_rate_repository.dart';
import 'package:mars_fx/services/service_locator.dart';
import 'package:mars_fx/theme/theme_constants.dart';

/// Subtle status bar at the bottom showing update status.
///
/// Doubles as the way into the settings: it is the only permanently visible
/// element outside the currency list, and the chevron marks it as a door.
class StatusBar extends StatelessWidget {
  final VoidCallback onTap;

  const StatusBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final repository = getIt<ExchangeRateRepository>();

    return ValueListenableBuilder<String>(
      valueListenable: repository.statusNotifier,
      builder: (context, status, _) {
        // Before the first successful fetch there is nothing to report, but the
        // door still needs to be there — fall back to naming the destination.
        final label = status.isEmpty ? 'Settings' : status;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TEXT_STYLE_STATUS),
                const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: COLOR_SECONDARY,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
