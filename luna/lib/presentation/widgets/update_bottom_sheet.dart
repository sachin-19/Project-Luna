import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/l10n.dart';
import '../providers/update_provider.dart';

/// Shows the update sheet if an update is available.
/// Call once per session after the home screen is mounted.
void checkAndShowUpdateSheet(BuildContext context, WidgetRef ref) {
  Future.delayed(const Duration(milliseconds: 500), () async {
    await ref.read(updateNotifierProvider.notifier).checkForUpdate();
    if (!context.mounted) return;
    final state = ref.read(updateNotifierProvider);
    if (state.status == UpdateStatus.available) {
      _show(context);
    }
  });
}

void _show(BuildContext context) => showUpdateBottomSheet(context);

/// Shows the update bottom sheet. Can be called from anywhere that has a
/// BuildContext, e.g. the settings screen manual-check button.
void showUpdateBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _UpdateSheet(),
  );
}

class _UpdateSheet extends ConsumerWidget {
  const _UpdateSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(updateNotifierProvider);
    final notifier = ref.read(updateNotifierProvider.notifier);
    final info = state.info;

    // Dismiss sheet once install is triggered.
    if (state.status == UpdateStatus.readyToInstall) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      });
    }

    final isMandatory = info?.isMandatory ?? false;
    final isDownloading = state.status == UpdateStatus.downloading;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.system_update_rounded,
                    color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMandatory ? context.l10n.updateRequired : context.l10n.updateAvailable,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (info != null)
                      Text(
                        context.l10n.updateVersion(info.latestVersion),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Release notes ─────────────────────────────────────────────────
          if (info?.releaseNotes.isNotEmpty == true) ...[
            Text(
              info!.releaseNotes,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
          ],

          // ── Progress bar ──────────────────────────────────────────────────
          if (isDownloading) ...[
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: state.progress,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(state.progress * 100).toInt()}%',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // ── Error message ─────────────────────────────────────────────────
          if (state.status == UpdateStatus.error) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.updateDownloadFailed,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onErrorContainer),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Buttons ───────────────────────────────────────────────────────
          Row(
            children: [
              // "Later" — only shown for optional updates when not downloading
              if (!isMandatory && !isDownloading) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notifier.dismissOptional();
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(context.l10n.updateLater),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: isDownloading ? null : notifier.startDownload,
                  child: isDownloading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          state.status == UpdateStatus.error
                              ? context.l10n.updateRetry
                              : context.l10n.updateNow,
                        ),
                ),
              ),
            ],
          ),

          // Prevent dismissal on mandatory updates with a note.
          if (isMandatory) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                context.l10n.updateMandatoryNote,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
