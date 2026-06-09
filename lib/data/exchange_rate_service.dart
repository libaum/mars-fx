import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches exchange rates from the Frankfurter API.
/// All rates are EUR-based.
class ExchangeRateService {
  static const _baseUrl = 'https://api.frankfurter.app';

  /// Returns a map of currency code → rate (EUR-based), or null on failure.
  Future<Map<String, double>?> fetchLatestRates() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/latest'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = json['rates'] as Map<String, dynamic>;

      final result = <String, double>{'EUR': 1.0};
      for (final entry in rates.entries) {
        result[entry.key] = (entry.value as num).toDouble();
      }
      return result;
    } catch (e) {
      print('[ExchangeRateService] fetch failed: $e');
      return null;
    }
  }
}
