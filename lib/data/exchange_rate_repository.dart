import 'package:flutter/foundation.dart';
import 'package:mars_fx/data/exchange_rate_service.dart';
import 'package:mars_fx/data/local_storage_service.dart';

/// Coordinates between the API service and local cache.
/// Provides reactive notifiers for rates and status.
class ExchangeRateRepository {
  final ExchangeRateService _service;
  final LocalStorageService _storage;

  final ValueNotifier<Map<String, double>> ratesNotifier =
      ValueNotifier(<String, double>{});
  final ValueNotifier<DateTime?> lastUpdatedNotifier = ValueNotifier(null);
  final ValueNotifier<String> statusNotifier = ValueNotifier('');

  ExchangeRateRepository(this._service, this._storage) {
    _loadCached();
    refreshRates();
  }

  void _loadCached() {
    final cached = _storage.getCachedRates();
    if (cached != null && cached.isNotEmpty) {
      ratesNotifier.value = cached;
      lastUpdatedNotifier.value = _storage.getLastUpdated();
      _updateStatus();
    }
  }

  Future<void> refreshRates() async {
    final rates = await _service.fetchLatestRates();
    if (rates != null && rates.isNotEmpty) {
      ratesNotifier.value = rates;
      final now = DateTime.now();
      lastUpdatedNotifier.value = now;
      await _storage.setCachedRates(rates);
      await _storage.setLastUpdated(now);
      _updateStatus();
    } else if (ratesNotifier.value.isNotEmpty) {
      // Keep using cached, but update status
      _updateStatus();
    }
  }

  void _updateStatus() {
    final lastUpdated = lastUpdatedNotifier.value;
    if (lastUpdated == null) {
      statusNotifier.value = '';
      return;
    }

    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inMinutes < 5) {
      statusNotifier.value = 'Updated just now';
    } else if (diff.inMinutes < 60) {
      statusNotifier.value = 'Updated ${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      statusNotifier.value = 'Updated ${diff.inHours}h ago';
    } else {
      statusNotifier.value = 'Using cached rates';
    }
  }
}
