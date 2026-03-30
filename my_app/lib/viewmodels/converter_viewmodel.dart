import '../services/exchange_api_service.dart';
import '../repositories/history_repository.dart';
import '../models/currency_rate.dart';

class ConverterViewModel {
  final ExchangeApiService _apiService;
  final HistoryRepository _historyRepository;
  
  String fromCurrency = 'RUB';
  String toCurrency = 'USD';
  String amount = '1000';
  String result = '0.00';
  bool isLoading = false;
  String? errorMessage;
  
  CurrencyRate? _currentRates;
  
  List<String> history = [];
  
  final Map<String, String> currencies = {
    'RUB': '🇷🇺 Российский рубль',
    'USD': '🇺🇸 Доллар США',
    'EUR': '🇪🇺 Евро',
    'GBP': '🇬🇧 Фунт стерлингов',
    'CNY': '🇨🇳 Китайский юань',
    'JPY': '🇯🇵 Японская иена',
    'KRW': '🇰🇷 Южнокорейская вона',
    'TRY': '🇹🇷 Турецкая лира',
    'KZT': '🇰🇿 Казахстанский тенге',
    'CHF': '🇨🇭 Швейцарский франк',
  };

  ConverterViewModel({
    required ExchangeApiService apiService,
    required HistoryRepository historyRepository,
  }) : _apiService = apiService,
       _historyRepository = historyRepository;

  Future<void> loadHistory() async {
    history = await _historyRepository.getHistory();
  }

  Future<void> fetchRates() async {
    isLoading = true;
    errorMessage = null;
    
    try {
      _currentRates = await _apiService.getRates(fromCurrency);
      convert();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  void convert() {
    if (_currentRates == null) {
      return;
    }
    
    double amountNum = double.tryParse(amount) ?? 0;
    
    if (fromCurrency == toCurrency) {
      result = amountNum.toStringAsFixed(2);
    } else if (_currentRates!.rates.containsKey(toCurrency)) {
      double rate = _currentRates!.rates[toCurrency]!;
      result = (amountNum * rate).toStringAsFixed(2);
    } else {
      result = 'Ошибка';
    }
  }

  Future<void> saveToHistory() async {
    String historyEntry = '$amount $fromCurrency → $result $toCurrency';
    await _historyRepository.addToHistory(historyEntry);
    history.add(historyEntry);
  }

  void updateFromCurrency(String currency) {
    fromCurrency = currency;
    fetchRates();
  }

  void updateToCurrency(String currency) {
    toCurrency = currency;
    convert();
  }

  void updateAmount(String value) {
    amount = value.isEmpty ? '0' : value;
    convert();
  }
}