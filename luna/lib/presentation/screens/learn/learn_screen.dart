import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/learn_provider.dart';
import '../../providers/user_provider.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  static const _topics = [
    ('basics', Icons.science_outlined, 'Basics'),
    ('nutrition', Icons.restaurant_outlined, 'Nutrition'),
    ('exercise', Icons.fitness_center_outlined, 'Exercise'),
    ('emotional', Icons.psychology_outlined, 'Emotional'),
    ('safety', Icons.shield_outlined, 'Safety'),
  ];

  static const _phases = [
    ('menstrual', 'Menstrual'),
    ('follicular', 'Follicular'),
    ('ovulation', 'Ovulation'),
    ('luteal', 'Luteal'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final filter = ref.watch(articleFilterProvider);
    final articlesAsync = ref.watch(articlesProvider);
    final featuredAsync = ref.watch(featuredArticlesProvider);
    final user = ref.watch(userStreamProvider).valueOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Learn', style: theme.textTheme.titleMedium),
          ),

          // ── Featured banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: featuredAsync.when(
              loading: () => const SizedBox(height: 8),
              error: (_, _) => const SizedBox.shrink(),
              data: (featured) {
                if (featured.isEmpty) return const SizedBox(height: 8);
                final article = featured.first;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: _FeaturedCard(article: article),
                );
              },
            ),
          ),

          // ── Youth safety banner ───────────────────────────────────────────
          if (user?.isYouth == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _YouthSafetyBanner(),
              ),
            ),

          // ── Filter chips ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topic',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: filter.topic == null,
                          onTap: () => ref
                              .read(articleFilterProvider.notifier)
                              .setTopic(null),
                        ),
                        const SizedBox(width: 8),
                        ..._topics.map((t) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: t.$3,
                                icon: t.$2,
                                selected: filter.topic == t.$1,
                                onTap: () => ref
                                    .read(articleFilterProvider.notifier)
                                    .setTopic(
                                        filter.topic == t.$1 ? null : t.$1),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phase',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All phases',
                          selected: filter.phase == null,
                          onTap: () => ref
                              .read(articleFilterProvider.notifier)
                              .setPhase(null),
                        ),
                        const SizedBox(width: 8),
                        ..._phases.map((p) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: p.$2,
                                selected: filter.phase == p.$1,
                                onTap: () => ref
                                    .read(articleFilterProvider.notifier)
                                    .setPhase(
                                        filter.phase == p.$1 ? null : p.$1),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Safety section ────────────────────────────────────────────────
          if (filter.topic == null || filter.topic == 'safety')
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _SafetySection(),
              ),
            ),

          // ── Article list ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            sliver: articlesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (articles) {
                if (articles.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyState());
                }
                return SliverList.separated(
                  itemCount: articles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _ArticleCard(article: articles[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured banner ───────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final Article article;
  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.push('/learn/article/${article.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer.withValues(alpha: 0.85),
              cs.secondaryContainer.withValues(alpha: 0.45),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Featured',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${article.readingTimeMin} min read',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.auto_stories_rounded, color: cs.primary, size: 40),
          ],
        ),
      ),
    );
  }
}

// ── Article card ──────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  static const Map<String, IconData> _topicIcons = {
    'basics': Icons.science_outlined,
    'nutrition': Icons.restaurant_outlined,
    'exercise': Icons.fitness_center_outlined,
    'emotional': Icons.psychology_outlined,
    'safety': Icons.shield_outlined,
  };

  static const Map<String, Color> _topicColors = {
    'basics': Color(0xFF10B981),
    'nutrition': Color(0xFFF97316),
    'exercise': Color(0xFF10B981),
    'emotional': Color(0xFF8B5CF6),
    'safety': Color(0xFFE53E6A),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final icon = _topicIcons[article.topic] ?? Icons.article_outlined;
    final color = _topicColors[article.topic] ?? cs.primary;

    return GestureDetector(
      onTap: () => context.push('/learn/article/${article.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    article.summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${article.readingTimeMin} min read',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Safety quick-access section ───────────────────────────────────────────────

class _SafetySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE53E6A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFE53E6A).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_phone_outlined,
                  color: const Color(0xFFE53E6A), size: 18),
              const SizedBox(width: 8),
              Text(
                'Need to talk to someone?',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFE53E6A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HelplineRow(name: 'iCall (free counselling)', number: '9152987821'),
          _HelplineRow(name: 'Childline (under 18)', number: '1098'),
          _HelplineRow(name: 'Women Helpline', number: '181'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () =>
                context.push('/learn/article/safety_02'),
            child: Text(
              'See all support services →',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelplineRow extends StatelessWidget {
  final String name;
  final String number;
  const _HelplineRow({required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            number,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Youth safety banner ───────────────────────────────────────────────────────

class _YouthSafetyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.child_friendly_outlined, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Some articles are tailored for your age group. Childline (1098) is always here if you need support.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, color: cs.onSurfaceVariant, size: 40),
          const SizedBox(height: 12),
          Text(
            'No articles match these filters.\nTry a different topic or phase.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
