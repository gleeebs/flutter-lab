import 'package:flutter/material.dart';
import '../repositories/history_repository.dart';
import 'calculator_screen.dart';
import 'converter_screen.dart';

class HistoryScreen extends StatefulWidget {
  final List<String> history;
  final HistoryRepository repository;
  
  const HistoryScreen({
    super.key,
    required this.history,
    required this.repository,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<String> _history;

  @override
  void initState() {
    super.initState();
    _history = List.from(widget.history);
  }

  Future<void> _clearHistory() async {
    await widget.repository.clearHistory();
    setState(() {
      _history.clear();
      widget.history.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('История очищена')),
    );
  }

  void _onHistoryItemTap(String item) {
    if (item.contains('→')) {
      final parts = item.split(' → ');
      if (parts.length == 2) {
        final amountPart = parts[0].split(' ');
        final resultPart = parts[1].split(' ');
        
        if (amountPart.length >= 2 && resultPart.length >= 2) {
          final amount = amountPart[0];
          final fromCurrency = amountPart[1];
          final toCurrency = resultPart[1];
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConverterScreen(
                history: widget.history,
                repository: widget.repository,
                initialAmount: amount,
                initialFromCurrency: fromCurrency,
                initialToCurrency: toCurrency,
              ),
            ),
          );
          return;
        }
      }
    } else {
       final parts = item.split(' = ');
    if (parts.length == 2) {
      final expression = parts[0];
      final result = parts[1];
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CalculatorScreen(
            initialExpression: expression,
            initialResult: result,
            history: widget.history,
            repository: widget.repository,
          ),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'История пуста',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _history[_history.length - 1 - index];
                final isConverter = item.contains('→');
                
                return ListTile(
                  leading: Icon(
                    isConverter ? Icons.currency_exchange : Icons.calculate,
                    color: isConverter ? Colors.green : Colors.blue,
                  ),
                  title: Text(
                    item,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _onHistoryItemTap(item),
                );
              },
            ),
    );
  }
}