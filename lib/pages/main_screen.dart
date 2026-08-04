import 'package:flutter/material.dart';
import 'package:mars_fx/logic/currency_list_manager.dart';
import 'package:mars_fx/logic/settings_manager.dart';
import 'package:mars_fx/pages/currency_search_screen.dart';
import 'package:mars_fx/pages/settings_screen.dart';
import 'package:mars_fx/pages/widgets/currency_row.dart';
import 'package:mars_fx/pages/widgets/status_bar.dart';
import 'package:mars_fx/services/service_locator.dart';
import 'package:mars_fx/theme/theme_constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _manager = getIt<CurrencyListManager>();
  final _settings = getIt<SettingsManager>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _settings.showLongNameNotifier,
                  builder: (context, showLongName, _) {
                    return ValueListenableBuilder<List<String>>(
                      valueListenable: _manager.visibleCurrenciesNotifier,
                      builder: (context, currencies, _) {
                        return ValueListenableBuilder<Map<String, String>>(
                          valueListenable: _manager.amountsNotifier,
                          builder: (context, amounts, _) {
                            return ValueListenableBuilder<String?>(
                              valueListenable: _manager.activeCurrencyNotifier,
                              builder: (context, activeCurrency, _) {
                                return ListView(
                                  children: [
                                    ...currencies.map(
                                      (code) => CurrencyRow(
                                        key: ValueKey(code),
                                        code: code,
                                        value: amounts[code] ?? '',
                                        isActive: code == activeCurrency,
                                        showLongName: showLongName,
                                        onTap: () => _onCurrencyTap(code),
                                        onLongPress: () =>
                                            _manager.moveCurrencyToTop(code),
                                        onValueChanged: (value) =>
                                            _onValueChanged(code, value),
                                        onDismissed: () =>
                                            _manager.removeCurrency(code),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                      ),
                                      child: _buildAddCurrencyButton(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const StatusBar(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _onCurrencyTap(String code) {
    final amounts = _manager.amountsNotifier.value;
    final currentValue = amounts[code] ?? '';
    final parsed = double.tryParse(currentValue) ?? 0;
    _manager.setAmount(code, parsed);
  }

  void _onValueChanged(String code, String value) {
    final parsed = double.tryParse(value) ?? 0;
    _manager.setAmount(code, parsed);
  }

  Widget _buildAddCurrencyButton(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const CurrencySearchScreen()),
        );
        if (result != null) {
          _manager.addCurrency(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          '+ Add currency',
          style: TEXT_STYLE_ADD_CURRENCY.copyWith(
            color: primary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
