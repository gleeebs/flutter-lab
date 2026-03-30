import 'package:shared_preferences/shared_preferences.dart';

class HistoryRepository {
  static const String _historyKey = 'calculator_history';
  final SharedPreferences _prefs;

  HistoryRepository(this._prefs);

  Future<List<String>> getHistory() async {
    final history = _prefs.getStringList(_historyKey);
    return history ?? [];
  }

  Future<void> addToHistory(String entry) async {
    final history = await getHistory();
    history.add(entry);
    await _prefs.setStringList(_historyKey, history);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }
}