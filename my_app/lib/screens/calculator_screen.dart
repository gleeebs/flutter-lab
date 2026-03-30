import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/calculator_viewmodel.dart';
import '../repositories/history_repository.dart';
import 'converter_screen.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  final String? initialExpression;
  final String? initialResult;
  final List<String>? history;
  final HistoryRepository? repository;
  
  const CalculatorScreen({
    super.key,
    this.initialExpression,
    this.initialResult,
    this.history,
    this.repository,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  CalculatorViewModel? _viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = widget.repository ?? HistoryRepository(prefs);
    final viewModel = CalculatorViewModel(historyRepository: repo);
    await viewModel.loadHistory();
    
    // Если есть начальные значения из истории
    if (widget.initialExpression != null && widget.initialResult != null) {
      viewModel.setExpressionAndResult(widget.initialExpression!, widget.initialResult!);
    }
    
    setState(() {
      _viewModel = viewModel;
      _isLoading = false;
    });
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
        title: const Text('EasyCalc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    history: _viewModel!.history,
                    repository: _viewModel!.historyRepository,
                  ),
                ),
              ).then((_) {
                _viewModel!.loadHistory().then((_) => setState(() {}));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Дисплей с двумя строками
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Маленькая строка с выражением
                Text(
                  _viewModel!.expression,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Большая строка с результатом
                Text(
                  _viewModel!.displayValue,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Кнопки
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildButtonRow(['%', 'CE', 'C', '⌫'], 
                    [Colors.white, Colors.white, Colors.white, Colors.white]),
                  _buildButtonRow(['1/x', 'xʸ', '√x', '÷'],
                    [Colors.white, Colors.white, Colors.white, Colors.blue.shade600]),
                  _buildButtonRow(['7', '8', '9', '×'],
                    [Colors.white, Colors.white, Colors.white, Colors.blue.shade600]),
                  _buildButtonRow(['4', '5', '6', '-'],
                    [Colors.white, Colors.white, Colors.white, Colors.blue.shade600]),
                  _buildButtonRow(['1', '2', '3', '+'],
                    [Colors.white, Colors.white, Colors.white, Colors.blue.shade600]),
                  _buildButtonRow(['+/-', '0', ',', '='],
                    [Colors.white, Colors.white, Colors.white, Colors.blue.shade600]),
                ],
              ),
            ),
          ),
          
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConverterScreen(
                      history: _viewModel!.history,
                      repository: _viewModel!.historyRepository,
                    ),
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
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> texts, List<Color> colors) {
    return Expanded(
      child: Row(
        children: List.generate(texts.length, (index) {
          return _calcButton(texts[index], colors[index]);
        }),
      ),
    );
  }

  Widget _calcButton(String text, Color bgColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _viewModel!.buttonPressed(text);
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: text == '0' ? 24 : 20,
                    fontWeight: FontWeight.w500,
                    color: bgColor == Colors.white ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}