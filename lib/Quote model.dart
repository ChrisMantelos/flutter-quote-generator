class Quote {
  final String content;
  final String author;
  final List<String> tags;

  Quote({required this.content, required this.author, this.tags = const []});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['content'] as String,
      author: json['author'] as String,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'author': author,
        'tags': tags,
      };

  @override
  bool operator ==(Object other) =>
      other is Quote && other.content == content && other.author == author;

  @override
  int get hashCode => Object.hash(content, author);
}
