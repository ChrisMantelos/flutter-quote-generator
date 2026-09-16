import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'quote_model.dart';

class FavoritesStorage {
  static const _key = 'favorite_quotes';

  Future<List<Quote>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((entry) => Quote.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<Quote> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = favorites.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }
}
