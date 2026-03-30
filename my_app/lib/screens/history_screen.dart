import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final items = [
            '15 + 27 = 42',
            '1000 RUB → 10.92 USD',
            '8 × 8 = 64',
            '√144 = 12',
            '25% от 200 = 50',
            '50 EUR → 4950 RUB',
          ];
          return ListTile(
            title: Text(
              items[index],
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}