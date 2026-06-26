import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers.dart';
import '../../../data/services/credential_service.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  static const _rose = Color(0xFFE53E6A);

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;
      await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
          );
      if (!mounted) return;
      context.go('/onboarding/identity');
      // Prompt to save credentials — Android sheet appears over onboarding.
      CredentialService.instance.saveCredentials(email, password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _friendlyError(e.code);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  String _friendlyError(String code) => switch (code) {
        'email-already-in-use' =>
          'An account with this email already exists.',
        'invalid-email' => 'Please enter a valid email address.',
        'weak-password' => 'Password must be at least 6 characters.',
        'network-request-failed' => 'No internet connection. Try again.',
        _ => 'Something went wrong. Please try again.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0508),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF200C17), Color(0xFF130A10), Color(0xFF0D0508)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white70),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Create account',
                    style: GoogleFonts.fraunces(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(duration: 450.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Back up your cycle data and restore it on any device.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.52),
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 450.ms),

                  const SizedBox(height: 40),

                  _DarkField(
                    controller: _emailCtrl,
                    label: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ).animate().fadeIn(delay: 140.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  _DarkField(
                    controller: _passCtrl,
                    label: 'Password',
                    obscureText: _obscurePass,
                    textInputAction: TextInputAction.next,
                    suffixIcon: _VisibilityToggle(
                      visible: !_obscurePass,
                      onToggle: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  _DarkField(
                    controller: _confirmCtrl,
                    label: 'Confirm password',
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submit,
                    suffixIcon: _VisibilityToggle(
                      visible: !_obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v != _passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ).animate().fadeIn(delay: 220.ms, duration: 400.ms),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFFFF6B8A),
                      ),
                    ).animate().fadeIn(),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rose,
                        foregroundColor: Colors.white,
                        shadowColor: _rose.withValues(alpha: 0.4),
                        elevation: 8,
                        disabledBackgroundColor:
                            _rose.withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Create account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 260.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () =>
                          context.pushReplacement('/auth/signin'),
                      child: Text(
                        'Already have an account? Sign in',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: _rose.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sign-in screen ─────────────────────────────────────────────────────────────

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  static const _rose = Color(0xFFE53E6A);

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _loading = false;
  String? _error;
  // Set to true when _submit() is called from _tryAutoSignIn() so we skip
  // re-saving credentials that are already in the manager (avoids the redundant
  // "Save password?" sheet that appears on every auto-sign-in).
  bool _fromCredentialManager = false;

  @override
  void initState() {
    super.initState();
    // Try to auto-sign-in from saved credentials (shows biometric prompt).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tryAutoSignIn();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Retrieves saved credentials via Android Credential Manager.
  /// If found (after biometric confirmation), auto-fills and submits the form.
  Future<void> _tryAutoSignIn() async {
    final saved = await CredentialService.instance.getCredentials();
    if (saved == null || !mounted) return;
    final email = saved.username;
    final password = saved.password;
    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      return;
    }
    _emailCtrl.text = email;
    _passCtrl.text = password;
    _fromCredentialManager = true;
    try {
      await _submit();
    } finally {
      _fromCredentialManager = false;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authRepo = ref.read(authRepositoryProvider);

      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;

      // ── Step 1: Authenticate only ────────────────────────────────────────────
      // Only FirebaseAuthException can be thrown here. Firestore errors are
      // handled separately below so sync failure never looks like auth failure.
      await authRepo.signIn(email: email, password: password);

      // Save credentials only on manual sign-in. Skip when the call came from
      // _tryAutoSignIn() — credentials are already stored and re-saving triggers
      // a redundant "Save password?" sheet from the OS.
      if (!_fromCredentialManager) {
        CredentialService.instance.saveCredentials(email, password);
      }

      final uid = authRepo.currentUid!;

      // ── Step 2: Decide new-device vs existing-device ─────────────────────────
      final userRepo = ref.read(userRepositoryProvider);
      final localUser = await userRepo.getUser();

      if (!mounted) return;

      if (localUser == null) {
        // New device — attempt Firestore restore, but don't block navigation if
        // rules aren't deployed yet or network is flaky.
        bool hadData = false;
        try {
          hadData =
              await ref.read(syncServiceProvider).restoreAll(uid);
        } catch (_) {
          // Sync failure: user still signed in; they can retry from Settings.
        }
        if (!mounted) return;
        context.go(hadData ? '/home' : '/onboarding/identity');
      } else {
        // Existing device — navigate home immediately, then sync in background.
        // Sync errors surface in the Settings sync status, not here.
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
        ref.read(syncNotifierProvider.notifier).sync();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _friendlyError(e.code);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  String _friendlyError(String code) => switch (code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Incorrect email or password.',
        'invalid-email' => 'Please enter a valid email address.',
        'user-disabled' => 'This account has been disabled.',
        'network-request-failed' => 'No internet connection. Try again.',
        'too-many-requests' =>
          'Too many attempts. Please wait a moment and try again.',
        _ => 'Something went wrong. Please try again.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0508),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF200C17), Color(0xFF130A10), Color(0xFF0D0508)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white70),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Welcome back',
                    style: GoogleFonts.fraunces(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(duration: 450.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to restore your data or sync a new device.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.52),
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 450.ms),

                  const SizedBox(height: 40),

                  _DarkField(
                    controller: _emailCtrl,
                    label: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ).animate().fadeIn(delay: 140.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  _DarkField(
                    controller: _passCtrl,
                    label: 'Password',
                    obscureText: _obscurePass,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submit,
                    suffixIcon: _VisibilityToggle(
                      visible: !_obscurePass,
                      onToggle: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      return null;
                    },
                  ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFFFF6B8A),
                      ),
                    ).animate().fadeIn(),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rose,
                        foregroundColor: Colors.white,
                        shadowColor: _rose.withValues(alpha: 0.4),
                        elevation: 8,
                        disabledBackgroundColor:
                            _rose.withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Sign in',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 220.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () =>
                          context.pushReplacement('/auth/signup'),
                      child: Text(
                        "Don't have an account? Create one",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: _rose.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;

  const _DarkField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white.withValues(alpha: 0.42),
          fontSize: 14,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE53E6A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B8A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B8A), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        errorStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFFF6B8A),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onToggle;
  const _VisibilityToggle({required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        color: Colors.white38,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}
