import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_articles.dart';
import 'user_provider.dart';

export '../../domain/entities/article.dart';

// ── Raw JSON cache ─────────────────────────────────────────────────────────

/// Loads and caches the articles.json asset. Underlying data never changes
/// at runtime, so a simple Provider (not FutureProvider) with a persistent
/// reference is enough.
final _articlesJsonProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final str = await rootBundle.loadString('assets/data/articles.json');
  return jsonDecode(str) as Map<String, dynamic>;
});

// ── Filter state ───────────────────────────────────────────────────────────

class ArticleFilter {
  const ArticleFilter({this.phase, this.topic});
  final String? phase;
  final String? topic;

  ArticleFilter copyWith({String? phase, String? topic, bool clearPhase = false, bool clearTopic = false}) =>
      ArticleFilter(
        phase: clearPhase ? null : (phase ?? this.phase),
        topic: clearTopic ? null : (topic ?? this.topic),
      );
}

class ArticleFilterNotifier extends Notifier<ArticleFilter> {
  @override
  ArticleFilter build() => const ArticleFilter();

  void setPhase(String? phase) => state = state.copyWith(
        phase: phase,
        clearPhase: phase == null,
      );

  void setTopic(String? topic) => state = state.copyWith(
        topic: topic,
        clearTopic: topic == null,
      );

  void clear() => state = const ArticleFilter();
}

final articleFilterProvider =
    NotifierProvider<ArticleFilterNotifier, ArticleFilter>(
  ArticleFilterNotifier.new,
);

// ── Article list provider ──────────────────────────────────────────────────

/// Filtered article list based on current [ArticleFilter] and user's age.
final articlesProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final jsonData = await ref.watch(_articlesJsonProvider.future);
  final filter = ref.watch(articleFilterProvider);
  final user = ref.watch(userStreamProvider).valueOrNull;

  return const GetArticles().execute(
    jsonData,
    phase: filter.phase,
    topic: filter.topic,
    isYouth: user?.isYouth ?? false,
  );
});

/// Featured articles (for the banner on Learn home).
final featuredArticlesProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final jsonData = await ref.watch(_articlesJsonProvider.future);
  final user = ref.watch(userStreamProvider).valueOrNull;
  return const GetArticles().featured(jsonData, isYouth: user?.isYouth ?? false);
});

/// Single article by ID.
final articleByIdProvider =
    FutureProvider.autoDispose.family<Article?, String>((ref, id) async {
  final jsonData = await ref.watch(_articlesJsonProvider.future);
  return const GetArticles().byId(jsonData, id);
});
