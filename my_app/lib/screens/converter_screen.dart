import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';

class ConverterScreen extends StatefulWidget {
  final List<String> history;
  const ConverterScreen({super.key, required this.history});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  String fromCurrency = 'RUB';
  String toCurrency = 'USD';
  String amount = '1000';
  String result = '0.00';
  
  // Примерные курсы для демонстрации (без API)
  final Map<String, double> rates = {
    'RUB': 1.0,
    'USD': 0.011,
    'EUR': 0.010,
    'GBP': 0.0086,
    'CNY': 0.079,
    'JPY': 1.64,
    'KRW': 16.0,
    'TRY': 0.41,
    'KZT': 5.8,
    'CHF': 0.0098,
  };
  
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

  void _convert() {
    double amountNum = double.tryParse(amount) ?? 0;
    
    if (fromCurrency == toCurrency) {
      result = amountNum.toStringAsFixed(2);
    } else if (rates.containsKey(fromCurrency) && rates.containsKey(toCurrency)) {
      // Конвертируем через RUB как базовую валюту
      double inRub = amountNum / rates[fromCurrency]!;
      double converted = inRub * rates[toCurrency]!;
      result = converted.toStringAsFixed(2);
    } else {
      result = 'Ошибка';
    }
    
    setState(() {});
  }

  void _saveToHistory() {
    String historyEntry = '$amount $fromCurrency → $result $toCurrency';
    widget.history.add(historyEntry);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранено в историю')),
    );
  }

  @override
  void initState() {
    super.initState();
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(history: widget.history),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Поле ввода суммы
            TextField(
              decoration: InputDecoration(
                labelText: 'Сумма',
                hintText: 'Введите сумму',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: amount),
              onChanged: (value) {
                amount = value.isEmpty ? '0' : value;
                _convert();
              },
            ),
            const SizedBox(height: 20),
            
            // Выбор исходной валюты
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Из валюты',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: fromCurrency,
              items: currencies.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  fromCurrency = value;
                  _convert();
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Выбор целевой валюты
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'В валюту',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: toCurrency,
              items: currencies.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  toCurrency = value;
                  _convert();
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Кнопка сохранения в историю
            ElevatedButton.icon(
              onPressed: _saveToHistory,
              icon: const Icon(Icons.save),
              label: const Text('Сохранить результат в историю'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Результат
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Text('Результат:', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    result,
                    style: const TextStyle(
                      fontSize: 40, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('$amount $fromCurrency → $toCurrency', 
                    style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CalculatorScreen(),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Конвертер',
          ),
        ],
      ),
    );
  }
}