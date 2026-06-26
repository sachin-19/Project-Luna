import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/feature_flags.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0508),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ───────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF200C17),
                  Color(0xFF130A10),
                  Color(0xFF0D0508),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Subtle radial highlight behind orb ────────────────────────────
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x28E53E6A),
                      Color(0x00E53E6A),
                    ],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── Orb + icon ───────────────────────────────────────────
                  _GlowOrb()
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.82, 0.82),
                        end: const Offset(1, 1),
                        duration: 800.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 36),

                  // ── App name ─────────────────────────────────────────────
                  Text(
                    'luna',
                    style: GoogleFonts.fraunces(
                      fontSize: 72,
                      fontWeight: FontWeight.w600,
                      color: _white,
                      height: 1.0,
                      letterSpacing: -1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 250.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 14),

                  // ── Tagline ───────────────────────────────────────────────
                  Text(
                    'Your cycle. Your story.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: _white.withValues(alpha: 0.52),
                      height: 1.4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 420.ms, duration: 500.ms),

                  const SizedBox(height: 28),

                  // ── Phase dots ────────────────────────────────────────────
                  _PhaseDots()
                      .animate()
                      .fadeIn(delay: 550.ms, duration: 500.ms),

                  const Spacer(flex: 3),

                  // ── Auth choice (when Firebase enabled) or single CTA ─────
                  if (kFirebaseEnabled) ...[
                    _CreateAccountButton()
                        .animate()
                        .fadeIn(delay: 750.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 750.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 12),
                    _SignInButton()
                        .animate()
                        .fadeIn(delay: 850.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    _LocalOnlyButton()
                        .animate()
                        .fadeIn(delay: 950.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      'No account needed. Data always stays on your device.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: _white.withValues(alpha: 0.24),
                      ),
                    ).animate().fadeIn(delay: 1050.ms, duration: 400.ms),
                  ] else ...[
                    _GetStartedButton()
                        .animate()
                        .fadeIn(delay: 750.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 750.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 12),
                    Text(
                      'Your data stays on your device.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _white.withValues(alpha: 0.28),
                      ),
                    ).animate().fadeIn(delay: 950.ms, duration: 400.ms),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glow orb ──────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  static const _rose = Color(0xFFE53E6A);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Mid glow ring
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _rose.withValues(alpha: 0.22),
                _rose.withValues(alpha: 0.0),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Inner circle with border
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _rose.withValues(alpha: 0.12),
            border: Border.all(
              color: _rose.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.water_drop_rounded,
              size: 44,
              color: _rose,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Phase dots ────────────────────────────────────────────────────────────────

class _PhaseDots extends StatelessWidget {
  static const _phases = [
    (Color(0xFFE53E6A), 'Menstrual'),
    (Color(0xFFF97316), 'Follicular'),
    (Color(0xFF10B981), 'Ovulation'),
    (Color(0xFF8B5CF6), 'Luteal'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _phases.length; i++) ...[
          _Dot(color: _phases[i].$1),
          if (i < _phases.length - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ── CTA buttons ───────────────────────────────────────────────────────────────

class _GetStartedButton extends StatelessWidget {
  static const _rose = Color(0xFFE53E6A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.go('/onboarding/identity'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _rose,
          foregroundColor: Colors.white,
          shadowColor: _rose.withValues(alpha: 0.4),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Get started',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  static const _rose = Color(0xFFE53E6A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => context.push('/auth/signup'),
        icon: const Icon(Icons.cloud_outlined, size: 20),
        label: Text(
          'Create account & sync',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _rose,
          foregroundColor: Colors.white,
          shadowColor: _rose.withValues(alpha: 0.4),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  static const _rose = Color(0xFFE53E6A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => context.push('/auth/signin'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: _rose.withValues(alpha: 0.55), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Sign in to existing account',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LocalOnlyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/onboarding/identity'),
      child: Text(
        'Continue without account',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
