import 'package:flutter/foundation.dart';
import 'package:mars_fx/data/exchange_rate_repository.dart';
import 'package:mars_fx/data/local_storage_service.dart';
import 'package:mars_fx/domain/currency_converter.dart';
import 'package:mars_fx/domain/currency_data.dart';
import 'package:mars_fx/services/service_locator.dart';

/// Manages the visible currency list, active input, and computed amounts.
class CurrencyListManager {
  final _repository = getIt<ExchangeRateRepository>();
  final _storage = getIt<LocalStorageService>();

  final ValueNotifier<List<String>> visibleCurrenciesNotifier =
      ValueNotifier([]);
  final ValueNotifier<String?> activeCurrencyNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, String>> amountsNotifier = ValueNotifier({});

  /// The raw numeric amount the user typed for the active currency
  double _activeAmount = 0;

  CurrencyListManager() {
    // Load persisted list or use defaults
    final saved = _storage.getVisibleCurrencies();
    visibleCurrenciesNotifier.value =
        saved ?? List.from(CurrencyData.defaultCurrencies);

    // Set first currency as active
    if (visibleCurrenciesNotifier.value.isNotEmpty) {
      activeCurrencyNotifier.value = visibleCurrenciesNotifier.value.first;
    }

    // Recalculate when rates change
    _repository.ratesNotifier.addListener(_recalculate);
  }

  /// Set the amount for a currency and recalculate all others.
  void setAmount(String currency, double amount) {
    activeCurrencyNotifier.value = currency;
    _activeAmount = amount;
    _recalculate();
  }

  /// Recalculate all currency amounts based on the active currency.
  void _recalculate() {
    final active = activeCurrencyNotifier.value;
    final rates = _repository.ratesNotifier.value;
    if (active == null || rates.isEmpty) return;

    final amounts = <String, String>{};
    for (final code in visibleCurrenciesNotifier.value) {
      if (code == active) {
        amounts[code] = _formatAmount(_activeAmount, code);
      } else {
        final converted =
            CurrencyConverter.convert(_activeAmount, active, code, rates);
        amounts[code] = converted != null ? _formatAmount(converted, code) : '';
      }
    }
    amountsNotifier.value = Map.from(amounts);
  }

  String _formatAmount(double value, String code) {
    if (value == 0) return '';
    // Currencies without a meaningful minor unit are always whole numbers —
    // even below 1, where a fractional yen or dong says nothing.
    if (CurrencyData.isZeroDecimal(code)) {
      final str = value.toStringAsFixed(0);
      // A sub-unit amount rounds away to nothing; show the placeholder
      // instead of a bare "0", same as the value == 0 case above.
      return str == '0' ? '' : str;
    }
    // For large values (>= 1), show max 2 decimal places, strip trailing zeros
    // For small values (< 1), show up to 4 decimal places
    if (value >= 1) {
      final str = value.toStringAsFixed(2);
      // Strip trailing zeros after decimal point
      if (str.contains('.')) {
        final trimmed = str.replaceAll(RegExp(r'0+$'), '');
        return trimmed.endsWith('.') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
      }
      return str;
    } else {
      final str = value.toStringAsFixed(4);
      final trimmed = str.replaceAll(RegExp(r'0+$'), '');
      return trimmed.endsWith('.') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    }
  }

  void addCurrency(String code) {
    final list = List<String>.from(visibleCurrenciesNotifier.value);
    if (!list.contains(code)) {
      list.add(code);
      visibleCurrenciesNotifier.value = list;
      _storage.setVisibleCurrencies(list);
      _recalculate();
    }
  }

  void removeCurrency(String code) {
    final list = List<String>.from(visibleCurrenciesNotifier.value);
    list.remove(code);
    visibleCurrenciesNotifier.value = list;
    _storage.setVisibleCurrencies(list);

    // If we removed the active currency, switch to the first one
    if (activeCurrencyNotifier.value == code && list.isNotEmpty) {
      activeCurrencyNotifier.value = list.first;
    }
    _recalculate();
  }

  /// Move a currency to the top of the list.
  void moveCurrencyToTop(String code) {
    final list = List<String>.from(visibleCurrenciesNotifier.value);
    if (list.remove(code)) {
      list.insert(0, code);
      visibleCurrenciesNotifier.value = list;
      _storage.setVisibleCurrencies(list);
    }
  }
}
