import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/learn_provider.dart';
import '../../providers/user_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleByIdProvider(articleId));
    final user = ref.watch(userStreamProvider).valueOrNull;

    return Scaffold(
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _NotFound(),
        data: (article) {
          if (article == null) return _NotFound();

          // Under-18 gate for 18+ content
          if ((user?.isYouth == true) && article.minAge >= 18) {
            return _AgeGate(article: article);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                expandedHeight: 120,
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.fromLTRB(56, 0, 16, 16),
                  title: Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Meta row ───────────────────────────────────────
                      Row(
                        children: [
                          _TopicBadge(topic: article.topic),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${article.readingTimeMin} min read',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          if (article.phases.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.loop_rounded,
                              size: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.phases
                                  .map((p) => _phaseLabel(p))
                                  .join(', '),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),

                      const Divider(height: 28),

                      // ── Article body ──────────────────────────────────
                      SimpleMarkdownBody(content: article.content),

                      // ── Safety footer for safety articles ─────────────
                      if (article.topic == 'safety') ...[
                        const SizedBox(height: 24),
                        _SafetyFooter(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _phaseLabel(String phase) => switch (phase) {
        'menstrual' => 'Menstrual',
        'follicular' => 'Follicular',
        'ovulation' => 'Ovulation',
        'luteal' => 'Luteal',
        _ => phase,
      };
}

// ── Simple Markdown renderer ──────────────────────────────────────────────────

/// Renders a subset of Markdown:
/// - `## ` and `# ` → headings
/// - `- ` lines → bullet list items
/// - `**text**` → bold inline
/// - `*text*` → italic inline (where not part of **)
/// Paragraphs are separated by blank lines.
class SimpleMarkdownBody extends StatelessWidget {
  final String content;
  const SimpleMarkdownBody({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Split into blocks on blank lines
    final blocks = content.split(RegExp(r'\n{2,}')).where((b) => b.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        final trimmed = block.trim();

        // ## Heading 2
        if (trimmed.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 6),
            child: Text(
              trimmed.substring(3),
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        // # Heading 1
        if (trimmed.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              trimmed.substring(2),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        // Bullet list: every line starting with `- `
        final lines = trimmed.split('\n');
        final isBulletBlock = lines.every((l) => l.trim().startsWith('- '));
        if (isBulletBlock) {
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines
                  .where((l) => l.trim().isNotEmpty)
                  .map((l) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5, right: 8),
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _InlineMarkdown(
                                text: l.trim().substring(2),
                                baseStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          );
        }

        // Mixed block: might have some `- ` lines and some plain lines
        // Treat as a paragraph
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: _InlineMarkdown(
            text: trimmed.replaceAll('\n', ' '),
            baseStyle: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Renders inline **bold** and *italic* markdown within a single text span.
class _InlineMarkdown extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  const _InlineMarkdown({required this.text, this.baseStyle});

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: _parse(text, baseStyle)));
  }

  static List<InlineSpan> _parse(String text, TextStyle? base) {
    final spans = <InlineSpan>[];
    // Match **bold** first, then *italic*
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    int cursor = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start), style: base));
      }
      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(1),
          style: base?.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(2),
          style: base?.copyWith(fontStyle: FontStyle.italic),
        ));
      }
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }

    return spans;
  }
}

// ── Topic badge ───────────────────────────────────────────────────────────────

class _TopicBadge extends StatelessWidget {
  final String topic;
  const _TopicBadge({required this.topic});

  static const Map<String, Color> _colors = {
    'basics': Color(0xFF10B981),
    'nutrition': Color(0xFFF97316),
    'exercise': Color(0xFF10B981),
    'emotional': Color(0xFF8B5CF6),
    'safety': Color(0xFFE53E6A),
  };

  static const Map<String, String> _labels = {
    'basics': 'Basics',
    'nutrition': 'Nutrition',
    'exercise': 'Exercise',
    'emotional': 'Emotional',
    'safety': 'Safety',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[topic] ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _labels[topic] ?? topic,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Safety footer ─────────────────────────────────────────────────────────────

class _SafetyFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_outline_rounded, color: cs.error, size: 16),
              const SizedBox(width: 8),
              Text(
                'If you need help right now',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SafetyRow(label: 'iCall (free counselling)', value: '9152987821'),
          _SafetyRow(label: 'Childline (under 18)', value: '1098'),
          _SafetyRow(label: 'Women Helpline', value: '181'),
          _SafetyRow(label: 'Vandrevala Foundation 24/7', value: '1860-2662-345'),
        ],
      ),
    );
  }
}

class _SafetyRow extends StatelessWidget {
  final String label;
  final String value;
  const _SafetyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodySmall),
          ),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Age gate ──────────────────────────────────────────────────────────────────

class _AgeGate extends StatelessWidget {
  final Article article;
  const _AgeGate({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, color: cs.primary, size: 48),
            const SizedBox(height: 20),
            Text(
              'This article is for adults (18+)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${article.title} contains content designed for adult readers. Luna shows you age-appropriate content based on your profile.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'If you need support, Childline (1098) is available 24/7.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Not found ─────────────────────────────────────────────────────────────────

class _NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Text(
          'Article not found.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
