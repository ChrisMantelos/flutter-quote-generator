import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'theme.dart';
import 'theme_storage.dart';
import 'quote_model.dart';
import 'quote_service.dart';
import 'favorites_storage.dart';
import 'daily_quote_storage.dart';
import 'favorites_screen.dart';

void main() {
  runApp(const QuoteApp());
}

class QuoteApp extends StatefulWidget {
  const QuoteApp({super.key});

  @override
  State<QuoteApp> createState() => _QuoteAppState();
}

class _QuoteAppState extends State<QuoteApp> {
  final ThemeStorage _themeStorage = ThemeStorage();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _themeStorage.loadIsDarkMode();
    if (mounted) setState(() => _isDarkMode = isDark);
  }

  Future<void> _toggleDarkMode() async {
    setState(() => _isDarkMode = !_isDarkMode);
    await _themeStorage.saveIsDarkMode(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final palette = _isDarkMode ? QuotePalette.dark : QuotePalette.light;
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;

    return MaterialApp(
      title: 'Quote Generator',
      theme: buildAppTheme(palette, brightness),
      home: QuoteScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      ),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const QuoteScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with SingleTickerProviderStateMixin {
  final QuoteService _service = QuoteService();
  final FavoritesStorage _favoritesStorage = FavoritesStorage();
  final DailyQuoteStorage _dailyStorage = DailyQuoteStorage();

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
    _loadInitialQuote();
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

  Future<void> _loadInitialQuote() async {
    final cached = await _dailyStorage.loadTodayQuote();
    if (cached != null) {
      setState(() {
        _quote = cached;
        _fromFallback = false;
        _loading = false;
      });
      _controller.forward(from: 0);
      return;
    }
    await _fetchQuote(saveAsDaily: true);
  }

  Future<void> _fetchQuote({bool saveAsDaily = false}) async {
    setState(() => _loading = true);
    final result = await _service.fetchRandomQuote(tag: _selectedTag);
    if (!mounted) return;
    setState(() {
      _quote = result.quote;
      _fromFallback = result.fromFallback;
      _loading = false;
    });
    _controller.forward(from: 0);
    if (saveAsDaily) {
      await _dailyStorage.saveTodayQuote(result.quote);
    }
  }

  bool get _isFavorite => _quote != null && _favorites.contains(_quote);

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

  Future<void> _shareQuote() async {
    if (_quote == null) return;
    final text = '"${_quote!.content}" - ${_quote!.author}';
    try {
      await Share.share(text);
    } catch (_) {
      _copyToClipboard();
    }
  }

  Future<void> _openFavorites() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()),
    );
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<QuotePalette>()!;

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
                      Text('Quote Generator', style: QuoteTextStyles.title(palette.ink)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.onToggleDarkMode,
                            icon: Icon(
                              widget.isDarkMode
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              color: palette.accent,
                            ),
                          ),
                          IconButton(
                            onPressed: _openFavorites,
                            icon: Icon(Icons.bookmark, color: palette.accent),
                          ),
                        ],
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
                        palette: palette,
                        onTap: () {
                          setState(() => _selectedTag = null);
                          _fetchQuote();
                        },
                      ),
                      ...availableTags.map((tag) => _TagChip(
                            label: tag,
                            selected: _selectedTag == tag,
                            palette: palette,
                            onTap: () {
                              setState(() => _selectedTag = tag);
                              _fetchQuote();
                            },
                          )),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: _loading
                          ? CircularProgressIndicator(color: palette.accent)
                          : FadeTransition(
                              opacity: _fade,
                              child: _QuoteCard(
                                quote: _quote,
                                fromFallback: _fromFallback,
                                palette: palette,
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
                          color: palette.accent,
                        ),
                      ),
                      IconButton(
                        onPressed: _quote == null ? null : _copyToClipboard,
                        icon: Icon(Icons.copy_outlined, color: palette.inkSoft),
                      ),
                      IconButton(
                        onPressed: _quote == null ? null : _shareQuote,
                        icon: Icon(Icons.share_outlined, color: palette.inkSoft),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: palette.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: _loading ? null : () => _fetchQuote(),
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
  final QuotePalette palette;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? palette.accentBg : Colors.transparent,
          border: Border.all(
            color: selected ? palette.accent : palette.chipBorder,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: QuoteTextStyles.chip(palette.ink)),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote? quote;
  final bool fromFallback;
  final QuotePalette palette;

  const _QuoteCard({
    required this.quote,
    required this.fromFallback,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Text('No quote yet.', style: QuoteTextStyles.author(palette.inkSoft));
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: palette.cardBg,
        border: Border.all(color: palette.chipBorder),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('"${quote!.content}"', style: QuoteTextStyles.quote(palette.ink, 22)),
          const SizedBox(height: 16),
          Text('- ${quote!.author}', style: QuoteTextStyles.author(palette.accent)),
          if (fromFallback) ...[
            const SizedBox(height: 12),
            Text(
              'OFFLINE - SHOWN FROM LOCAL COLLECTION',
              style: QuoteTextStyles.label(palette.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}
