import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'quote_model.dart';
import 'quote_service.dart';
import 'favorites_storage.dart';
import 'favorites_screen.dart';

void main() {
  runApp(const QuoteApp());
}

class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quote Generator',
      theme: ThemeData(
        scaffoldBackgroundColor: QuoteColors.paper,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: QuoteColors.accent,
          surface: QuoteColors.paper,
        ),
      ),
      home: const QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with SingleTickerProviderStateMixin {
  final _service = QuoteService();
  final _favoritesStorage = FavoritesStorage();

  Quote? _quote;
  bool _fromFallback = false;
  bool _loading = false;
  String? _selectedTag;
  List<Quote> _favorites = [];

  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _loadFavorites();
    _loadQuote();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesStorage.loadFavorites();
    if (mounted) setState(() => _favorites = favorites);
  }

  Future<void> _loadQuote() async {
    setState(() => _loading = true);
    final result = await _service.fetchRandomQuote(tag: _selectedTag);
    if (!mounted) return;
    setState(() {
      _quote = result.quote;
      _fromFallback = result.fromFallback;
      _loading = false;
    });
    _controller.forward(from: 0);
  }

  bool get _isFavorite =>
      _quote != null && _favorites.contains(_quote);

  Future<void> _toggleFavorite() async {
    if (_quote == null) return;
    setState(() {
      if (_isFavorite) {
        _favorites.remove(_quote);
      } else {
        _favorites.add(_quote!);
      }
    });
    await _favoritesStorage.saveFavorites(_favorites);
  }

  void _copyToClipboard() {
    if (_quote == null) return;
    Clipboard.setData(ClipboardData(text: '"${_quote!.content}" - ${_quote!.author}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _openFavorites() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FavoritesScreen(storage: _favoritesStorage)),
    );
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quote Generator', style: QuoteText.title),
                      IconButton(
                        onPressed: _openFavorites,
                        icon: Icon(Icons.bookmark, color: QuoteColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TagChip(
                        label: 'all',
                        selected: _selectedTag == null,
                        onTap: () {
                          setState(() => _selectedTag = null);
                          _loadQuote();
                        },
                      ),
                      ...availableTags.map((tag) => _TagChip(
                            label: tag,
                            selected: _selectedTag == tag,
                            onTap: () {
                              setState(() => _selectedTag = tag);
                              _loadQuote();
                            },
                          )),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: _loading
                          ? const CircularProgressIndicator(color: QuoteColors.accent)
                          : FadeTransition(
                              opacity: _fade,
                              child: _QuoteCard(
                                quote: _quote,
                                fromFallback: _fromFallback,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quote == null ? null : _toggleFavorite,
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: QuoteColors.accent,
                        ),
                      ),
                      IconButton(
                        onPressed: _quote == null ? null : _copyToClipboard,
                        icon: Icon(Icons.copy_outlined, color: QuoteColors.inkSoft),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: QuoteColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: _loading ? null : _loadQuote,
                        child: const Text('New quote'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TagChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? QuoteColors.accentBg : Colors.transparent,
          border: Border.all(
            color: selected ? QuoteColors.accent : QuoteColors.chipBorder,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: QuoteText.chip),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote? quote;
  final bool fromFallback;

  const _QuoteCard({required this.quote, required this.fromFallback});

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Text('No quote yet.', style: QuoteText.author);
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: QuoteColors.chipBorder),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: QuoteColors.ink.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('"${quote!.content}"', style: QuoteText.quote(22)),
          const SizedBox(height: 16),
          Text('- ${quote!.author}', style: QuoteText.author),
          if (fromFallback) ...[
            const SizedBox(height: 12),
            Text('OFFLINE - SHOWN FROM LOCAL COLLECTION', style: QuoteText.label),
          ],
        ],
      ),
    );
  }
}
