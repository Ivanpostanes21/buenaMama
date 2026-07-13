import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../theme/app_colors.dart';
import '../../widgets/animated_login_button.dart';
import '../../widgets/animated_text_field.dart';
import '../../widgets/bounce_checkbox.dart';
import '../../widgets/window_controls.dart';
import '../../window_setup.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Entry animation: fade + slide up (600ms, easeOutCubic).
  late final AnimationController _entryController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _entryController,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
      );

  // Horizontal shake played on a failed login.
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  // Controls the card fade-out that plays after a successful login.
  bool _cardVisible = true;

  LoginButtonState _buttonState = LoginButtonState.idle;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_buttonState != LoginButtonState.idle) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate empty fields before submitting.
    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in both fields.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _buttonState = LoginButtonState.loading;
    });

    // Simulated backend call.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final bool valid = email == 'admin@test.com' && password == '123456';

    if (valid) {
      setState(() => _buttonState = LoginButtonState.success);
      // Let the checkmark draw, then enter the app.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      await _enterApp(guest: false);
    } else {
      setState(() => _buttonState = LoginButtonState.idle);
      _showError('Invalid email or password.');
    }
  }

  /// Transition from the login window into the main app: fade the card out,
  /// resize/center the window, then fade in the dashboard.
  Future<void> _enterApp({required bool guest}) async {
    setState(() => _cardVisible = false);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await enterAppWindow();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => MainScreen(isGuest: guest),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgBase,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
          ),
        ),
        child: Column(
          children: [
            // Thin lime brand strip across the very top of the window.
            Container(
              height: 4,
              decoration:
                  const BoxDecoration(gradient: AppColors.buttonGradient),
            ),
            _buildHeader(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: _buildAnimatedCard(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Draggable header area with the window controls in the top-right corner.
  Widget _buildHeader() {
    return DragToMoveArea(
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'BUENAMAMA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                  letterSpacing: 2.5,
                ),
              ),
              WindowControls(),
            ],
          ),
        ),
      ),
    );
  }

  /// The card wrapped with the fade-out (on success) and shake (on failure).
  Widget _buildAnimatedCard() {
    return AnimatedOpacity(
      opacity: _cardVisible ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          // Damped sine shake: a few oscillations that decay to zero.
          final double t = _shakeController.value;
          final double dx = math.sin(t * math.pi * 4) * 12 * (1 - t);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    final bool fieldsEnabled = _buttonState == LoginButtonState.idle;

    return Container(
      width: 344,
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Neutral depth shadow.
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          // Faint green glow.
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          const SizedBox(height: 18),
          const Text(
            'BuenaMAMA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to continue',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          AnimatedTextField(
            controller: _emailController,
            hintText: 'Email or username',
            icon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            enabled: fieldsEnabled,
          ),
          const SizedBox(height: 16),
          AnimatedTextField(
            controller: _passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            enabled: fieldsEnabled,
            onSubmitted: (_) => _handleLogin(),
            suffix: _buildPasswordToggle(),
          ),
          _buildErrorMessage(),
          const SizedBox(height: 14),
          _buildRememberRow(),
          const SizedBox(height: 24),
          AnimatedLoginButton(
            state: _buttonState,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 14),
          _buildGuestButton(fieldsEnabled),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    // Gradient-ring circular container holding the brand logo, with a soft
    // green glow behind it. Scales in as part of the entry animation.
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: AppColors.logoGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.35),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordToggle() {
    return IconButton(
      splashRadius: 18,
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          key: ValueKey(_obscurePassword),
          size: 19,
          color: AppColors.muted,
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _errorMessage == null ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: _errorMessage == null
            ? const SizedBox(width: double.infinity)
            : Container(
                margin: const EdgeInsets.only(top: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 15, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BounceCheckbox(
          value: _rememberMe,
          label: 'Remember me',
          onChanged: (v) => setState(() => _rememberMe = v),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.primaryDark,
          ),
          onPressed: () {},
          child: const Text(
            'Forgot password?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// Secondary, outlined action: continue without an account. Uses a lime
  /// outline that fills with the 10% tint on hover.
  Widget _buildGuestButton(bool enabled) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: enabled ? _handleGuest : null,
        icon: const Icon(Icons.person_outline, size: 19),
        label: const Text('Continue as Guest'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: BorderSide(
            color: AppColors.primaryGreen.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStatePropertyAll(AppColors.primaryTint),
        ),
      ),
    );
  }

  void _handleGuest() {
    if (_buttonState != LoginButtonState.idle) return;
    _enterApp(guest: true);
  }
}
