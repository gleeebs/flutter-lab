import 'dart:math';
import '../repositories/history_repository.dart';

class CalculatorViewModel {
  final HistoryRepository historyRepository;
  
  String _display = '0';
  String _expression = '';
  String _currentOperation = '';
  double? _firstNumber;
  bool _isNewOperation = true;
  bool _isDecimal = false;
  
  List<String> history = [];

  CalculatorViewModel({required this.historyRepository});

  String get displayValue => _display;
  String get expression => _expression.isEmpty ? '' : _expression;

  Future<void> loadHistory() async {
    history = await historyRepository.getHistory();
  }

  void setExpressionAndResult(String expression, String result) {
    _expression = expression;
    _display = result;
    _isNewOperation = true;
  }

  void buttonPressed(String value) {
    if (value == 'C') {
      _display = '0';
      _expression = '';
      _currentOperation = '';
      _firstNumber = null;
      _isNewOperation = true;
      _isDecimal = false;
    } 
    else if (value == 'CE') {
      _display = '0';
      _isNewOperation = true;
      _isDecimal = false;
    }
    else if (value == '⌫') {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
        if (_display == '-') _display = '0';
      } else {
        _display = '0';
        _isNewOperation = true;
      }
      _isDecimal = _display.contains('.');
    }
    else if (value == '=') {
      _calculateResult();
    }
    else if (value == '+' || value == '-' || value == '×' || value == '÷') {
      if (_firstNumber != null && !_isNewOperation) {
        _calculateResult();
      }
      _firstNumber = double.parse(_display);
      _currentOperation = value;
      _expression = '${_formatNumber(_firstNumber!)} $value';
      _isNewOperation = true;
      _isDecimal = false;
    }
    else if (value == '%') {
      double num = double.parse(_display);
      double result = num / 100;
      String expression = '${_formatNumber(num)}%';
      String resultStr = _formatNumber(result);
      
      // Сохраняем в историю
      _saveToHistory(expression, resultStr);
      
      _display = resultStr;
      _removeTrailingZero();
      _expression = expression;
      _isNewOperation = true;
      _isDecimal = _display.contains('.');
    }
    else if (value == '+/-') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    }
    else if (value == '1/x') {
      double num = double.parse(_display);
      if (num != 0) {
        double result = 1 / num;
        String expression = '1/${_formatNumber(num)}';
        String resultStr = _formatNumber(result);
        
        // Сохраняем в историю
        _saveToHistory(expression, resultStr);
        
        _display = resultStr;
        _removeTrailingZero();
        _expression = expression;
      } else {
        _display = 'Ошибка';
      }
      _isNewOperation = true;
    }
    else if (value == 'xʸ') {
      _firstNumber = double.parse(_display);
      _currentOperation = '^';
      _expression = '${_formatNumber(_firstNumber!)} ^';
      _isNewOperation = true;
      _isDecimal = false;
    }
    else if (value == '√x') {
      double num = double.parse(_display);
      if (num >= 0) {
        double result = sqrt(num);
        String expression = '√${_formatNumber(num)}';
        String resultStr = _formatNumber(result);
        
        // Сохраняем в историю
        _saveToHistory(expression, resultStr);
        
        _display = resultStr;
        _removeTrailingZero();
        _expression = expression;
      } else {
        _display = 'Ошибка';
      }
      _isNewOperation = true;
    }
    else if (value == ',') {
      if (!_isDecimal) {
        _display += '.';
        _isDecimal = true;
      }
      _isNewOperation = false;
    }
    else {
      if (_isNewOperation) {
        _display = value;
        _isNewOperation = false;
      } else {
        _display = (_display == '0') ? value : _display + value;
      }
      _isDecimal = _display.contains('.');
    }
  }

  void _calculateResult() async {
    if (_firstNumber != null && _currentOperation.isNotEmpty) {
      double secondNumber = double.parse(_display);
      double result = 0;
      
      switch (_currentOperation) {
        case '+':
          result = _firstNumber! + secondNumber;
          break;
        case '-':
          result = _firstNumber! - secondNumber;
          break;
        case '×':
          result = _firstNumber! * secondNumber;
          break;
        case '÷':
          if (secondNumber != 0) {
            result = _firstNumber! / secondNumber;
          } else {
            _display = 'Ошибка';
            return;
          }
          break;
        case '^':
          result = pow(_firstNumber!, secondNumber).toDouble();
          break;
      }
      
      String fullExpression = '${_formatNumber(_firstNumber!)} $_currentOperation ${_formatNumber(secondNumber)}';
      String resultStr = _formatNumber(result);
      
      // Сохраняем в историю
      await _saveToHistory(fullExpression, resultStr);
      
      _expression = fullExpression;
      _display = resultStr;
      _removeTrailingZero();
      _firstNumber = null;
      _currentOperation = '';
      _isNewOperation = true;
      _isDecimal = _display.contains('.');
    }
  }

  Future<void> _saveToHistory(String expression, String result) async {
    String historyEntry = '$expression = $result';
    await historyRepository.addToHistory(historyEntry);
    history.add(historyEntry);
  }

  String _formatNumber(double num) {
    if (num == num.toInt()) {
      return num.toInt().toString();
    }
    // Ограничиваем до 10 знаков после запятой
    String str = num.toString();
    if (str.contains('.') && str.length > 15) {
      str = num.toStringAsFixed(10);
      str = str.replaceAll(RegExp(r'0*$'), '');
      if (str.endsWith('.')) {
        str = str.substring(0, str.length - 1);
      }
    }
    return str;
  }

  void _removeTrailingZero() {
    if (_display.contains('.')) {
      _display = _display.replaceAll(RegExp(r'0*$'), '');
      if (_display.endsWith('.')) {
        _display = _display.substring(0, _display.length - 1);
      }
    }
  }
}