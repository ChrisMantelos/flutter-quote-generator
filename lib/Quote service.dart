import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'quote_model.dart';

const List<String> availableTags = [
  'wisdom',
  'inspirational',
  'life',
  'success',
  'happiness',
];

const List<Quote> _fallbackQuotes = [
  Quote(
    content: 'The only way to do great work is to love what you do.',
    author: 'Steve Jobs',
    tags: ['inspirational', 'success'],
  ),
  Quote(
    content: 'In the middle of difficulty lies opportunity.',
    author: 'Albert Einstein',
    tags: ['wisdom'],
  ),
  Quote(
    content: 'Life is what happens when you are busy making other plans.',
    author: 'John Lennon',
    tags: ['life'],
  ),
  Quote(
    content: 'Happiness is not something ready made. It comes from your own actions.',
    author: 'Dalai Lama',
    tags: ['happiness'],
  ),
  Quote(
    content: 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
    author: 'Winston Churchill',
    tags: ['success', 'wisdom'],
  ),
  Quote(
    content: 'The unexamined life is not worth living.',
    author: 'Socrates',
    tags: ['wisdom', 'life'],
  ),
];

class QuoteFetchResult {
  final Quote quote;
  final bool fromFallback;

  QuoteFetchResult({required this.quote, required this.fromFallback});
}

class QuoteService {
  final String baseUrl;
  final Random _random = Random();

  QuoteService({this.baseUrl = 'https://api.quotable.io'});

  Future<QuoteFetchResult> fetchRandomQuote({String? tag}) async {
    final query = tag != null ? '?tags=$tag' : '';
    final uri = Uri.parse('$baseUrl/random$query');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return QuoteFetchResult(quote: Quote.fromJson(data), fromFallback: false);
      }
    } catch (_) {
      // Falls through to the local fallback below.
    }

    return QuoteFetchResult(quote: _pickFallback(tag), fromFallback: true);
  }

  Quote _pickFallback(String? tag) {
    final pool = tag == null
        ? _fallbackQuotes
        : _fallbackQuotes.where((q) => q.tags.contains(tag)).toList();
    final source = pool.isEmpty ? _fallbackQuotes : pool;
    return source[_random.nextInt(source.length)];
  }
}
