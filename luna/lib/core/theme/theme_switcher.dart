import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Attach this key to the [RepaintBoundary] that wraps the app navigator.
/// [animateThemeToggle] uses it to capture the current frame before switching.
final themeSwitcherKey = GlobalKey();

/// Call this whenever the theme changes.
///
/// 1. Captures the current screen as a GPU image (capped at 2× to keep the
///    image small — indistinguishable during a 350 ms animation).
/// 2. Inserts an overlay showing the old screenshot (no visible change yet).
/// 3. Calls [toggle] → theme switches instantly beneath the overlay.
/// 4. Animates an expanding circle clipped from the overlay, revealing the
///    new theme beneath — the same "radial reveal" iOS uses for dark mode.
///
/// Uses clipPath + PathFillType.evenOdd instead of saveLayer + BlendMode.clear.
/// No offscreen GPU buffer is allocated per frame — efficient on all devices.
Future<void> animateThemeToggle({
  required BuildContext context,
  required VoidCallback toggle,
}) async {
  final boundary = themeSwitcherKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;

  // Fallback: no boundary found — just toggle without animation.
  if (boundary == null) {
    toggle();
    return;
  }

  // Cap at 2× — halves texture size on 3× flagship screens while being
  // completely indistinguishable during a 350 ms animation.
  final captureRatio =
      math.min(MediaQuery.devicePixelRatioOf(context), 2.0);
  ui.Image image;
  try {
    image = await boundary.toImage(pixelRatio: captureRatio);
  } catch (_) {
    toggle();
    return;
  }

  if (!context.mounted) {
    image.dispose();
    return;
  }

  final overlay = Overlay.of(context, rootOverlay: true);

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CircularRevealOverlay(
      image: image,
      onDone: () {
        entry.remove();
        image.dispose();
      },
    ),
  );

  // Insert overlay first so toggle renders invisibly beneath.
  overlay.insert(entry);
  toggle();
}

// ── Overlay widget ────────────────────────────────────────────────────────────

class _CircularRevealOverlay extends StatefulWidget {
  final ui.Image image;
  final VoidCallback onDone;

  const _CircularRevealOverlay({
    required this.image,
    required this.onDone,
  });

  @override
  State<_CircularRevealOverlay> createState() => _CircularRevealOverlayState();
}

class _CircularRevealOverlayState extends State<_CircularRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _reveal = CurvedAnimation(
      parent: _controller,
      // easeOutCubic: fast start → gradual deceleration.
      // Feels immediately responsive vs easeInOutCubic which starts slow.
      curve: Curves.easeOutCubic,
    );
    // Start on the next frame — by then the new theme has rendered beneath.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) widget.onDone();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _reveal,
      builder: (_, __) => SizedBox.expand(
        child: CustomPaint(
          painter: _RevealPainter(
            image: widget.image,
            revealFraction: _reveal.value,
          ),
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

/// Draws the old screenshot clipped to the area OUTSIDE a growing circle.
/// The new theme is visible inside the hole naturally (rendered beneath the
/// overlay). Uses clipPath with PathFillType.evenOdd — zero offscreen buffers,
/// no saveLayer. The GPU uses the stencil buffer instead.
///
/// PathFillType.evenOdd logic:
///   path = screenRect + circle (two sub-paths)
///   Inside circle     → 2 ray crossings = even → NOT in path → not drawn
///   Inside rect only  → 1 ray crossing  = odd  → IN path     → drawn (old UI)
class _RevealPainter extends CustomPainter {
  final ui.Image image;
  final double revealFraction;

  const _RevealPainter({
    required this.image,
    required this.revealFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Radius needed to completely cover the farthest screen corner.
    final maxRadius = math.sqrt(
      math.pow(math.max(center.dx, size.width - center.dx), 2) +
          math.pow(math.max(center.dy, size.height - center.dy), 2),
    );
    final holeRadius = maxRadius * revealFraction;

    canvas.save();

    if (holeRadius > 0) {
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(Rect.fromCircle(center: center, radius: holeRadius));
      path.fillType = PathFillType.evenOdd;
      canvas.clipPath(path);
    }

    // Old screenshot — only painted in the clipped ring outside the hole.
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..filterQuality = FilterQuality.low,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_RevealPainter old) =>
      old.revealFraction != revealFraction;
}
