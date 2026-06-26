import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared scaffold for all onboarding screens.
/// Handles the progress bar, back button, and consistent layout.
class OnboardingScaffold extends StatelessWidget {
  final int stepIndex;    // 0-based
  final int totalSteps;
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final bool showBack;

  const OnboardingScaffold({
    super.key,
    required this.stepIndex,
    this.totalSteps = 8,
    required this.title,
    this.subtitle,
    required this.body,
    this.primaryAction,
    this.secondaryAction,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final progress = (stepIndex + 1) / totalSteps;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Progress bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showBack)
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      if (showBack) const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: cs.surfaceContainerHigh,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cs.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${stepIndex + 1}/$totalSteps',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(title, style: theme.textTheme.headlineMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: body,
              ),
            ),

            // ── Actions ────────────────────────────────────────────────
            if (primaryAction != null || secondaryAction != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ignore: use_null_aware_elements
                    if (primaryAction != null) primaryAction!,
                    if (secondaryAction != null) ...[
                      const SizedBox(height: 12),
                      secondaryAction!,
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
