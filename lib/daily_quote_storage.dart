import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'quote_model.dart';

class DailyQuoteStorage {
  static const _dateKey = 'daily_quote_date';
  static const _quoteKey = 'daily_quote_value';

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<Quote?> loadTodayQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_dateKey);
    if (savedDate != _todayKey()) return null;

    final raw = prefs.getString(_quoteKey);
    if (raw == null) return null;

    return Quote.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveTodayQuote(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey, _todayKey());
    await prefs.setString(_quoteKey, jsonEncode(quote.toJson()));
  }
}
