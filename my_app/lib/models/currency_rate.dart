class CurrencyRate {
  final String base;
  final Map<String, double> rates;
  final DateTime timestamp;

  CurrencyRate({
    required this.base,
    required this.rates,
    required this.timestamp,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> ratesJson = json['conversion_rates'];
    final Map<String, double> rates = {};
    
    ratesJson.forEach((key, value) {
      rates[key] = (value as num).toDouble();
    });

    return CurrencyRate(
      base: json['base_code'],
      rates: rates,
      timestamp: DateTime.now(),
    );
  }
}