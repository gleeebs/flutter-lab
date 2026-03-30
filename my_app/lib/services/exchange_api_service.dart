import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';

class ExchangeApiService {
  static const String apiKey = 'bb770b888c4cd1a96f744e70';
  static const String baseUrl = 'https://v6.exchangerate-api.com/v6';

  Future<CurrencyRate> getRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$apiKey/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['result'] == 'success') {
          return CurrencyRate.fromJson(data);
        } else {
          throw Exception('API error: ${data['error-type']}');
        }
      } else {
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}