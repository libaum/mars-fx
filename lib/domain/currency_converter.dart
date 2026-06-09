/// Pure calculation logic for currency conversion.
/// All rates are EUR-based (EUR = 1.0).
class CurrencyConverter {
  /// Convert [amount] from [from] currency to [to] currency.
  /// Returns null if rates are missing for either currency.
  static double? convert(
    double amount,
    String from,
    String to,
    Map<String, double> rates,
  ) {
    final fromRate = rates[from];
    final toRate = rates[to];
    if (fromRate == null || toRate == null || fromRate == 0) return null;
    return amount / fromRate * toRate;
  }
}
