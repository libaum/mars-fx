import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for persisting app state.
class LocalStorageService {
  static const _keyCachedRates = 'cached_rates';
  static const _keyLastUpdated = 'last_updated';
  static const _keyVisibleCurrencies = 'visible_currencies';
  static const _keyThemeIsDark = 'theme_is_dark';
  static const _keyShowLongName = 'show_long_name';

  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  static Future<LocalStorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  /// Cached exchange rates
  Map<String, double>? getCachedRates() {
    final json = _prefs.getString(_keyCachedRates);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return null;
    }
  }

  Future<void> setCachedRates(Map<String, double> rates) async {
    await _prefs.setString(_keyCachedRates, jsonEncode(rates));
  }

  /// Last update timestamp
  DateTime? getLastUpdated() {
    final ms = _prefs.getInt(_keyLastUpdated);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastUpdated(DateTime time) async {
    await _prefs.setInt(_keyLastUpdated, time.millisecondsSinceEpoch);
  }

  /// Visible currencies list
  List<String>? getVisibleCurrencies() {
    final list = _prefs.getStringList(_keyVisibleCurrencies);
    return list;
  }

  Future<void> setVisibleCurrencies(List<String> currencies) async {
    await _prefs.setStringList(_keyVisibleCurrencies, currencies);
  }

  /// Theme mode
  bool? getThemeIsDark() => _prefs.getBool(_keyThemeIsDark);

  Future<void> setThemeIsDark(bool isDark) async {
    await _prefs.setBool(_keyThemeIsDark, isDark);
  }

  /// Display settings
  bool getShowLongName() => _prefs.getBool(_keyShowLongName) ?? false;
  Future<void> setShowLongName(bool v) => _prefs.setBool(_keyShowLongName, v);
}
