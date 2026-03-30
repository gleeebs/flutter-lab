import 'package:flutter/material.dart';
import 'converter_screen.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

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
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
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
            child: const Text(
              '0',
              style: TextStyle(
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
                  MaterialPageRoute(builder: (context) => const ConverterScreen()),
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
              onTap: () {},
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