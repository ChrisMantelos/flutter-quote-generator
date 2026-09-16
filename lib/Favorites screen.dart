import 'package:flutter/material.dart';
import 'theme.dart';
import 'quote_model.dart';
import 'favorites_storage.dart';

class FavoritesScreen extends StatefulWidget {
  final FavoritesStorage storage;

  const FavoritesScreen({super.key, required this.storage});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Quote> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favorites = await widget.storage.loadFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _loading = false;
    });
  }

  Future<void> _remove(Quote quote) async {
    setState(() => _favorites.remove(quote));
    await widget.storage.saveFavorites(_favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuoteColors.paper,
      appBar: AppBar(
        backgroundColor: QuoteColors.paper,
        elevation: 0,
        title: Text('Favorites', style: QuoteText.title.copyWith(fontSize: 22)),
        iconTheme: const IconThemeData(color: QuoteColors.ink),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: QuoteColors.accent))
          : _favorites.isEmpty
              ? Center(
                  child: Text('No favorites saved yet.', style: QuoteText.author),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final quote = _favorites[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: QuoteColors.chipBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('"${quote.content}"', style: QuoteText.quote(16)),
                                const SizedBox(height: 8),
                                Text('- ${quote.author}', style: QuoteText.author),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _remove(quote),
                            icon: Icon(Icons.delete_outline, color: QuoteColors.inkSoft),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
