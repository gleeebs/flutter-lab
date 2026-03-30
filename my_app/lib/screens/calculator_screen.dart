import 'package:flutter/material.dart';
import 'converter_screen.dart';
import 'history_screen.dart';
import 'dart:math';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String _currentOperation = '';
  double? _firstNumber;
  bool _isNewOperation = true;
  bool _isDecimal = false;
  
  // Список для истории
  List<String> history = [];

  void _buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        // Полная очистка
        display = '0';
        _currentOperation = '';
        _firstNumber = null;
        _isNewOperation = true;
        _isDecimal = false;
      } 
      else if (value == 'CE') {
        // Очистка текущего ввода
        display = '0';
        _isNewOperation = true;
        _isDecimal = false;
      }
      else if (value == '⌫') {
        // Удаление последнего символа
        if (display.length > 1) {
          display = display.substring(0, display.length - 1);
          if (display == '-') display = '0';
        } else {
          display = '0';
          _isNewOperation = true;
        }
        _isDecimal = display.contains('.');
      }
      else if (value == '=') {
        _calculateResult();
      }
      else if (value == '+' || value == '-' || value == '×' || value == '÷') {
        if (_firstNumber != null && !_isNewOperation) {
          _calculateResult();
        }
        _firstNumber = double.parse(display);
        _currentOperation = value;
        _isNewOperation = true;
        _isDecimal = false;
      }
      else if (value == '%') {
        double num = double.parse(display);
        display = (num / 100).toString();
        _removeTrailingZero();
        _isNewOperation = false;
      }
      else if (value == '+/-') {
        if (display.startsWith('-')) {
          display = display.substring(1);
        } else if (display != '0') {
          display = '-$display';
        }
      }
      else if (value == '1/x') {
        double num = double.parse(display);
        if (num != 0) {
          display = (1 / num).toString();
          _removeTrailingZero();
        } else {
          display = 'Ошибка';
        }
        _isNewOperation = true;
      }
      else if (value == 'xʸ') {
        _firstNumber = double.parse(display);
        _currentOperation = '^';
        _isNewOperation = true;
        _isDecimal = false;
      }
      else if (value == '√x') {
        double num = double.parse(display);
        if (num >= 0) {
          display = sqrt(num).toString();
          _removeTrailingZero();
        } else {
          display = 'Ошибка';
        }
        _isNewOperation = true;
      }
      else if (value == ',') {
        if (!_isDecimal) {
          display += '.';
          _isDecimal = true;
        }
        _isNewOperation = false;
      }
      else {
        // Цифры
        if (_isNewOperation) {
          display = value;
          _isNewOperation = false;
        } else {
          display = (display == '0') ? value : display + value;
        }
        _isDecimal = display.contains('.');
      }
    });
  }

  void _calculateResult() {
    if (_firstNumber != null && _currentOperation.isNotEmpty) {
      double secondNumber = double.parse(display);
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
            display = 'Ошибка';
            return;
          }
          break;
        case '^':
          result = pow(_firstNumber!, secondNumber).toDouble();
          break;
      }
      
      // Сохраняем в историю
      String historyEntry = '${_formatNumber(_firstNumber!)} $_currentOperation ${_formatNumber(secondNumber)} = ${_formatNumber(result)}';
      history.add(historyEntry);
      
      display = _formatNumber(result);
      _removeTrailingZero();
      _firstNumber = null;
      _currentOperation = '';
      _isNewOperation = true;
      _isDecimal = display.contains('.');
    }
  }

  String _formatNumber(double num) {
    if (num == num.toInt()) {
      return num.toInt().toString();
    }
    return num.toString();
  }

  void _removeTrailingZero() {
    if (display.contains('.')) {
      display = display.replaceAll(RegExp(r'0*$'), '');
      if (display.endsWith('.')) {
        display = display.substring(0, display.length - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  builder: (context) => HistoryScreen(history: history),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Дисплей
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            alignment: Alignment.bottomRight,
            width: double.infinity,
            child: Text(
              display,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Кнопки
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Ряд 1: %, CE, C, ⌫
                  Expanded(
                    child: Row(
                      children: [
                        _calcButton('%', Colors.grey.shade200, Colors.black87),
                        _calcButton('CE', Colors.grey.shade200, Colors.black87),
                        _calcButton('C', Colors.grey.shade200, Colors.black87),
                        _calcButton('⌫', Colors.grey.shade200, Colors.black87),
                      ],
                    ),
                  ),
                  // Ряд 2: 1/x, xʸ, √x, ÷
                  Expanded(
                    child: Row(
                      children: [
                        _calcButton('1/x', Colors.grey.shade200, Colors.black87),
                        _calcButton('xʸ', Colors.grey.shade200, Colors.black87),
                        _calcButton('√x', Colors.grey.shade200, Colors.black87),
                        _calcButton('÷', Colors.blue.shade600, Colors.white),
                      ],
                    ),
                  ),
                  // Ряд 3: 7, 8, 9, ×
                  Expanded(
                    child: Row(
                      children: [
                        _calcButton('7', Colors.white, Colors.black87),
                        _calcButton('8', Colors.white, Colors.black87),
                        _calcButton('9', Colors.white, Colors.black87),
                        _calcButton('×', Colors.blue.shade600, Colors.white),
                      ],
                    ),
                  ),
                  // Ряд 4: 4, 5, 6, -
                  Expanded(
                    child: Row(
                      children: [
                        _calcButton('4', Colors.white, Colors.black87),
                        _calcButton('5', Colors.white, Colors.black87),
                        _calcButton('6', Colors.white, Colors.black87),
                        _calcButton('-', Colors.blue.shade600, Colors.white),
                      ],
                    ),
                  ),
                  // Ряд 5: 1, 2, 3, +
                  Expanded(
                    child: Row(
                      children: [
                        _calcButton('1', Colors.white, Colors.black87),
                        _calcButton('2', Colors.white, Colors.black87),
                        _calcButton('3', Colors.white, Colors.black87),
                        _calcButton('+', Colors.blue.shade600, Colors.white),
                      ],
                    ),
                  ),
                  // Ряд 6: +/-, 0, ,, =
                  Expanded(
                    child: Row(
                      children: [
                        _calcButton('+/-', Colors.white, Colors.black87),
                        _calcButton('0', Colors.white, Colors.black87),
                        _calcButton(',', Colors.white, Colors.black87),
                        _calcButton('=', Colors.blue.shade600, Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Нижняя навигация
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConverterScreen(history: history),
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

  Widget _calcButton(String text, Color bgColor, Color textColor) {
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
              onTap: () => _buttonPressed(text),
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: text == '0' ? 24 : 20,
                    fontWeight: FontWeight.w500,
                    color: textColor,
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