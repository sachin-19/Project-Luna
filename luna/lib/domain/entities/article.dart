/// An educational article in the health library.
///
/// Articles are loaded from `assets/data/articles.json` — no network required.
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.topic,
    required this.readingTimeMin,
    this.phases = const [],
    this.featured = false,
    this.minAge = 0,
  });

  /// Unique identifier (e.g. "cycle_basics_01").
  final String id;

  final String title;

  /// One-sentence teaser shown in the article list card.
  final String summary;

  /// Full body content in simple Markdown (# ## - * **).
  final String content;

  /// Semantic topic — drives the filter chips.
  /// Values: 'basics' | 'nutrition' | 'exercise' | 'emotional' | 'safety'
  final String topic;

  /// Cycle phases this article is most relevant to (empty = all phases).
  final List<String> phases;

  /// When true, surfaced in the "Featured" banner on the Learn home.
  final bool featured;

  /// Users younger than this age see a soft gate before the article.
  /// 0 = shown to everyone.
  final int minAge;

  final int readingTimeMin;

  factory Article.fromJson(Map<String, dynamic> j) => Article(
        id: j['id'] as String,
        title: j['title'] as String,
        summary: j['summary'] as String,
        content: j['content'] as String,
        topic: j['topic'] as String,
        phases: (j['phases'] as List?)?.cast<String>() ?? [],
        featured: (j['featured'] as bool?) ?? false,
        minAge: (j['minAge'] as int?) ?? 0,
        readingTimeMin: (j['readingTimeMin'] as int?) ?? 3,
      );
}
