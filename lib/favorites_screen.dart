import 'package:flutter/material.dart';
import 'theme.dart';
import 'quote_model.dart';
import 'favorites_storage.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesStorage _storage = FavoritesStorage();
  List<Quote> _favorites = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favorites = await _storage.loadFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _loading = false;
    });
  }

  Future<void> _remove(Quote quote) async {
    setState(() => _favorites.remove(quote));
    await _storage.saveFavorites(_favorites);
  }

  List<Quote> get _filtered {
    if (_query.trim().isEmpty) return _favorites;
    final query = _query.trim().toLowerCase();
    return _favorites.where((quote) {
      return quote.author.toLowerCase().contains(query) ||
          quote.content.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<QuotePalette>()!;
    final visible = _filtered;

    return Scaffold(
      backgroundColor: palette.paper,
      appBar: AppBar(
        backgroundColor: palette.paper,
        elevation: 0,
        title: Text(
          'Favorites',
          style: QuoteTextStyles.title(palette.ink).copyWith(fontSize: 22),
        ),
        iconTheme: IconThemeData(color: palette.ink),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: palette.accent))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    style: TextStyle(color: palette.ink),
                    decoration: InputDecoration(
                      hintText: 'Search by author or keyword...',
                      hintStyle: TextStyle(color: palette.inkSoft),
                      prefixIcon: Icon(Icons.search, color: palette.inkSoft),
                      filled: true,
                      fillColor: palette.cardBg,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: palette.chipBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _favorites.isEmpty
                      ? Center(
                          child: Text(
                            'No favorites saved yet.',
                            style: QuoteTextStyles.author(palette.inkSoft),
                          ),
                        )
                      : visible.isEmpty
                          ? Center(
                              child: Text(
                                'No matches found.',
                                style: QuoteTextStyles.author(palette.inkSoft),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: visible.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final quote = visible[index];
                                return Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: palette.cardBg,
                                    border: Border.all(color: palette.chipBorder),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '"${quote.content}"',
                                              style: QuoteTextStyles.quote(palette.ink, 16),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '- ${quote.author}',
                                              style: QuoteTextStyles.author(palette.accent),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _remove(quote),
                                        icon: Icon(Icons.delete_outline, color: palette.inkSoft),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
