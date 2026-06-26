import '../entities/article.dart';

/// Loads and filters the health library articles.
///
/// Pure Dart — no Flutter imports. Caller supplies the parsed JSON.
class GetArticles {
  const GetArticles();

  /// Returns all articles, applying [phase] and [topic] filters if non-null.
  /// Articles with [Article.minAge] > 0 are excluded when [isYouth] is true
  /// and the article requires an age above 17.
  List<Article> execute(
    Map<String, dynamic> json, {
    String? phase,
    String? topic,
    bool isYouth = false,
  }) {
    final rawList = (json['articles'] as List).cast<Map<String, dynamic>>();
    var articles = rawList.map(Article.fromJson).toList();

    // Age gate: hide articles marked for 18+ from youth users
    if (isYouth) {
      articles = articles.where((a) => a.minAge < 18).toList();
    }

    // Phase filter: article matches if it declares no phases (= all) or includes the given phase
    if (phase != null) {
      articles = articles
          .where((a) => a.phases.isEmpty || a.phases.contains(phase))
          .toList();
    }

    // Topic filter
    if (topic != null) {
      articles = articles.where((a) => a.topic == topic).toList();
    }

    return articles;
  }

  /// Returns the single article with [id], or null if not found.
  Article? byId(Map<String, dynamic> json, String id) {
    final rawList = (json['articles'] as List).cast<Map<String, dynamic>>();
    try {
      return rawList
          .map(Article.fromJson)
          .firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns all featured articles.
  List<Article> featured(Map<String, dynamic> json, {bool isYouth = false}) {
    return execute(json, isYouth: isYouth)
        .where((a) => a.featured)
        .toList();
  }
}
