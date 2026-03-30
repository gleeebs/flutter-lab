import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';

class ExchangeApiService {
  static const String apiKey = 'bb770b888c4cd1a96f744e70';
  static const String baseUrl = 'https://v6.exchangerate-api.com/v6';

  static const Map<String, double> defaultRates = {
    'RUB': 1.0,
    'USD': 0.012,
    'EUR': 0.010,
    'GBP': 0.0092,
    'CNY': 0.084,
    'JPY': 1.96,
    'KRW': 18.54,
    'TRY': 0.41,
    'KZT': 5.92,
    'CHF': 0.0098,
  };

  Future<CurrencyRate> getRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$apiKey/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          return CurrencyRate.fromJson(data);
        }
      }
    } catch (e) {
      print('API error: $e');
    }
    
    return CurrencyRate(
      base: baseCurrency,
      rates: defaultRates,
      timestamp: DateTime.now(),
    );
  }
}