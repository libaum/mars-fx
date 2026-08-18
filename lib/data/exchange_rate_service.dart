import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches exchange rates from the ExchangeRate-API open endpoint.
/// All rates are EUR-based.
class ExchangeRateService {
  static const _baseUrl = 'https://open.er-api.com/v6';

  /// Returns a map of currency code → rate (EUR-based), or null on failure.
  Future<Map<String, double>?> fetchLatestRates() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/latest/EUR'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['result'] != 'success') return null;
      final rates = json['rates'] as Map<String, dynamic>;

      // EUR is included in the response, but pin it explicitly: the whole
      // conversion model assumes EUR == 1.0.
      final result = <String, double>{'EUR': 1.0};
      for (final entry in rates.entries) {
        if (entry.key == 'EUR') continue;
        result[entry.key] = (entry.value as num).toDouble();
      }
      return result;
    } catch (e) {
      print('[ExchangeRateService] fetch failed: $e');
      return null;
    }
  }
}
