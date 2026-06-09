import 'package:flutter/material.dart';
import 'package:mars_fx/data/exchange_rate_repository.dart';
import 'package:mars_fx/services/service_locator.dart';
import 'package:mars_fx/theme/theme_constants.dart';

/// Subtle status bar at the bottom showing update status.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = getIt<ExchangeRateRepository>();

    return ValueListenableBuilder<String>(
      valueListenable: repository.statusNotifier,
      builder: (context, status, _) {
        if (status.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Text(
            status,
            style: TEXT_STYLE_STATUS,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
