import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/enums.dart';

// Phase arc lengths as fractions of the full circle (28-day default)
// Menstrual: 5 days, Follicular: 8 days, Ovulation: 3 days, Luteal: 12 days
const _phaseFractions = {
  CyclePhase.menstrual: 5 / 28,
  CyclePhase.follicular: 8 / 28,
  CyclePhase.ovulation: 3 / 28,
  CyclePhase.luteal: 12 / 28,
};

// Drawing order — wheel starts at 12 o'clock (day 1 = top)
const _phaseOrder = [
  CyclePhase.menstrual,
  CyclePhase.follicular,
  CyclePhase.ovulation,
  CyclePhase.luteal,
];

class CycleWheel extends StatefulWidget {
  final int cycleDay;        // 1-indexed; 0 = no active cycle
  final int cycleLength;     // total cycle length in days
  final CyclePhase currentPhase;
  final double size;

  const CycleWheel({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    required this.currentPhase,
    this.size = 260,
  });

  @override
  State<CycleWheel> createState() => _CycleWheelState();
}

class _CycleWheelState extends State<CycleWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _CycleWheelPainter(
          cycleDay: widget.cycleDay,
          cycleLength: widget.cycleLength,
          currentPhase: widget.currentPhase,
          animationValue: _animation.value,
          cs: cs,
        ),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: _WheelCenter(
              cycleDay: widget.cycleDay,
              currentPhase: widget.currentPhase,
            ),
          ),
        ),
      ),
    );
  }
}

class _CycleWheelPainter extends CustomPainter {
  final int cycleDay;
  final int cycleLength;
  final CyclePhase currentPhase;
  final double animationValue;
  final ColorScheme cs;

  _CycleWheelPainter({
    required this.cycleDay,
    required this.cycleLength,
    required this.currentPhase,
    required this.animationValue,
    required this.cs,
  });

  static const _startAngle = -math.pi / 2; // 12 o'clock
  static const _strokeWidth = 22.0;
  static const _gapAngle = 0.03; // small gap between phase arcs
  static const _needleLength = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (_strokeWidth / 2) - 4;

    // ── Phase arcs ─────────────────────────────────────────────────────────
    double currentAngle = _startAngle;
    for (final phase in _phaseOrder) {
      final fraction = _phaseFractions[phase]!;
      final sweepAngle =
          (fraction * 2 * math.pi - _gapAngle) * animationValue;

      final paint = Paint()
        ..color = _phaseColor(phase).withValues(
          alpha: phase == currentPhase ? 1.0 : 0.35,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = phase == currentPhase ? _strokeWidth + 4 : _strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle + _gapAngle / 2,
        sweepAngle,
        false,
        paint,
      );

      currentAngle += fraction * 2 * math.pi;
    }

    // ── Track ring (background) ────────────────────────────────────────────
    final trackPaint = Paint()
      ..color = cs.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius + _strokeWidth / 2 + 6, trackPaint);
    canvas.drawCircle(center, radius - _strokeWidth / 2 - 6, trackPaint);

    // ── Today needle ───────────────────────────────────────────────────────
    if (cycleDay > 0 && animationValue > 0.5) {
      final needleAngle = _startAngle +
          (cycleDay - 1) / cycleLength * 2 * math.pi;
      final innerR = radius - _strokeWidth / 2 - 4;
      final outerR = radius + _strokeWidth / 2 + 4 + _needleLength;

      final needleStart = Offset(
        center.dx + innerR * math.cos(needleAngle),
        center.dy + innerR * math.sin(needleAngle),
      );
      final needleEnd = Offset(
        center.dx + outerR * math.cos(needleAngle),
        center.dy + outerR * math.sin(needleAngle),
      );

      final needlePaint = Paint()
        ..color = cs.onSurface
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(needleStart, needleEnd, needlePaint);

      // Needle dot
      canvas.drawCircle(needleEnd, 4, Paint()..color = cs.onSurface);
    }
  }

  Color _phaseColor(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstrual => const Color(0xFFE53E6A),
      CyclePhase.follicular => const Color(0xFFF97316),
      CyclePhase.ovulation => const Color(0xFF10B981),
      CyclePhase.luteal => const Color(0xFF8B5CF6),
    };
  }

  @override
  bool shouldRepaint(_CycleWheelPainter old) =>
      old.cycleDay != cycleDay ||
      old.currentPhase != currentPhase ||
      old.animationValue != animationValue;
}

class _WheelCenter extends StatelessWidget {
  final int cycleDay;
  final CyclePhase currentPhase;

  const _WheelCenter({required this.cycleDay, required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasData = cycleDay > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasData) ...[
          Text(
            cycleDay.toString(),
            style: theme.textTheme.displayMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          Text(
            'day',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
        ] else
          Icon(Icons.water_drop_outlined, size: 36, color: cs.onSurfaceVariant),
      ],
    );
  }
}
