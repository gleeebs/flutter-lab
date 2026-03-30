import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final List<String> history;
  const HistoryScreen({super.key, required this.history});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  void _clearHistory() {
    setState(() {
      widget.history.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('История очищена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История'),
        actions: [
          if (widget.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: widget.history.isEmpty
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
              itemCount: widget.history.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    widget.history[widget.history.length - 1 - index],
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