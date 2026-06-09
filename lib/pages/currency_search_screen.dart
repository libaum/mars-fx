import 'package:flutter/material.dart';
import 'package:mars_fx/domain/currency_data.dart';
import 'package:mars_fx/logic/currency_list_manager.dart';
import 'package:mars_fx/services/service_locator.dart';
import 'package:mars_fx/theme/theme_constants.dart';

/// Full-screen search for adding a new currency.
class CurrencySearchScreen extends StatefulWidget {
  const CurrencySearchScreen({super.key});

  @override
  State<CurrencySearchScreen> createState() => _CurrencySearchScreenState();
}

class _CurrencySearchScreenState extends State<CurrencySearchScreen> {
  final _manager = getIt<CurrencyListManager>();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> get _filteredCurrencies {
    final visible = _manager.visibleCurrenciesNotifier.value;
    final all = CurrencyData.currencies.entries
        .where((e) => !visible.contains(e.key))
        .toList();

    if (_query.isEmpty) return all;

    final q = _query.toLowerCase();
    return all
        .where((e) =>
            e.key.toLowerCase().contains(q) ||
            e.value.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TEXT_STYLE_SEARCH_INPUT.copyWith(color: primary),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'Search currencies',
                        hintStyle: TEXT_STYLE_SEARCH_INPUT.copyWith(
                          color: primary.withValues(alpha: 0.25),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _query = value);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        color: primary.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Divider(
                color: primary.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            // Currency list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                itemCount: _filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final entry = _filteredCurrencies[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(context, entry.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TEXT_STYLE_SEARCH_CODE.copyWith(
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.value,
                            style: TEXT_STYLE_SEARCH_NAME,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
