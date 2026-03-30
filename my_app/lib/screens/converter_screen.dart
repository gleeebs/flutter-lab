import 'package:flutter/material.dart';
import '../viewmodels/converter_viewmodel.dart';
import '../services/exchange_api_service.dart';
import '../repositories/history_repository.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';

class ConverterScreen extends StatefulWidget {
  final List<String> history;
  final HistoryRepository repository;
  final String? initialAmount;
  final String? initialFromCurrency;
  final String? initialToCurrency;
  final String? initialResult;
  
  const ConverterScreen({
    super.key,
    required this.history,
    required this.repository,
    this.initialAmount,
    this.initialFromCurrency,
    this.initialToCurrency,
    this.initialResult,
  });

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  ConverterViewModel? _viewModel;
  bool _isLoading = true;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    final apiService = ExchangeApiService();
    final viewModel = ConverterViewModel(
      apiService: apiService,
      historyRepository: widget.repository,
    );
    await viewModel.loadHistory();
    
    if (widget.initialAmount != null) {
      viewModel.amount = widget.initialAmount!;
      _amountController.text = widget.initialAmount!;
    }
    if (widget.initialFromCurrency != null) {
      viewModel.fromCurrency = widget.initialFromCurrency!;
    }
    if (widget.initialToCurrency != null) {
      viewModel.toCurrency = widget.initialToCurrency!;
    }
    if (widget.initialResult != null) {
      viewModel.result = widget.initialResult!;
    }
    
    await viewModel.fetchRates();
    
    setState(() {
      _viewModel = viewModel;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convertAndSave() {
    _viewModel!.convert();
    _viewModel!.saveToHistory();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранено в историю')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _viewModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  builder: (context) => HistoryScreen(
                    history: _viewModel!.history,
                    repository: widget.repository,
                  ),
                ),
              ).then((_) {
                _viewModel!.loadHistory().then((_) => setState(() {}));
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _viewModel!.fetchRates().then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
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
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    String value = _amountController.text;
                    if (value.isEmpty) value = '0';
                    _viewModel!.updateAmount(value);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Установить', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Из валюты',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: _viewModel!.fromCurrency,
              items: _viewModel!.currencies.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _viewModel!.updateFromCurrency(value);
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'В валюту',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: _viewModel!.toCurrency,
              items: _viewModel!.currencies.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _viewModel!.updateToCurrency(value);
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _convertAndSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Сохранить в историю', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 30),
            
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
                  if (_viewModel!.isLoading)
                    const CircularProgressIndicator()
                  else if (_viewModel!.errorMessage != null)
                    Text(
                      _viewModel!.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      _viewModel!.result,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  const SizedBox(height: 5),
                  if (!_viewModel!.isLoading && _viewModel!.errorMessage == null)
                    Text(
                      '${_viewModel!.amount} ${_viewModel!.fromCurrency} → ${_viewModel!.toCurrency}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
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
                builder: (context) => const CalculatorScreen(),
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