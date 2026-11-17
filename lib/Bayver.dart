import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ───────────────────────── Supabase ─────────────────────────
// Paste your values here, or run with:
// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://xkdtmrhhqgyjcxuuhfyc.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_l1oPGLAvjOsJw-DKOhki0g_ePyyiAlQ',
);

SupabaseClient get supabase => Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  runApp(const BayverApp());
}

// ───────────────────────── Theme ─────────────────────────
// Black and green, with the neon dialled down to a deeper emerald.

class BayColors {
  static const bg = Color(0xFF050A08);
  static const card = Color(0xFF0C1512);
  static const neon = Color(0xFF2FC774); // primary green (was bright neon)
  static const lime = Color(0xFF8DCB4A); // end colour of the button gradient
  static const gold = Color(0xFFE5B93B);
  static const orange = Color(0xFFE8803A);
  static const blue = Color(0xFF4C97E8);
  static const border = Color(0xFF2E7A52);
  static const text = Color(0xFFEAF7EF);
  static const muted = Color(0xFF9DB5A8);
  static const ink = Color(0xFF04110A); // dark text on green buttons
  static const tint = Color(0xFF12301E); // selected / subtle green background
}

/// Display font (Rajdhani) for headings, like the original design.
TextStyle display(
  double size, {
  Color color = BayColors.text,
  double spacing = 1,
  double? height,
  List<Shadow>? shadows,
}) => GoogleFonts.rajdhani(
  fontSize: size,
  fontWeight: FontWeight.w700,
  color: color,
  letterSpacing: spacing,
  height: height,
  shadows: shadows,
);

class BayverApp extends StatelessWidget {
  const BayverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bayver',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: BayColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: BayColors.neon,
          surface: BayColors.card,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: BayColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: display(24),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: BayColors.card,
          contentTextStyle: const TextStyle(color: BayColors.text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: BayColors.border),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ───────────────────────── Helpers ─────────────────────────

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Accepts 0712345678, 0112345678, 712345678, +254712345678, 254712345678.
/// Returns +254XXXXXXXXX or null if invalid.
String? normalizeKePhone(String input) {
  var s = input.replaceAll(RegExp(r'[\s\-()]'), '');
  if (s.startsWith('+254')) {
    s = s.substring(4);
  } else if (s.startsWith('254')) {
    s = s.substring(3);
  } else if (s.startsWith('0')) {
    s = s.substring(1);
  }
  if (!RegExp(r'^[17][0-9]{8}$').hasMatch(s)) return null;
  return '+254$s';
}

bool isValidEmail(String s) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s.trim());

InputDecoration bayInputDecoration({String? hint, Widget? suffix}) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: BayColors.muted),
    suffixIcon: suffix,
    counterText: '',
    filled: true,
    fillColor: BayColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: border(BayColors.border),
    enabledBorder: border(BayColors.border),
    focusedBorder: border(BayColors.neon),
    errorBorder: border(BayColors.orange),
    focusedErrorBorder: border(BayColors.orange),
    errorStyle: const TextStyle(color: BayColors.orange),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: BayColors.muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _BayBackground extends StatelessWidget {
  const _BayBackground({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.1),
          radius: 1.3,
          colors: [Color(0xFF0F4A28), Color(0xFF06100C), BayColors.bg],
          stops: [0, 0.55, 1],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// ───────────────────────── Auth gate ─────────────────────────
// Signed out -> AuthScreen. Signed in -> ProfileGate (Player Passport check) -> app.

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? supabase.auth.currentSession;
        return session == null ? const AuthScreen() : const ProfileGate();
      },
    );
  }
}

// ───────────────────────── Welcome: create account / sign in ─────────────────────────

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _signUp = true;
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _email.text.trim();
      if (_signUp) {
        final res = await supabase.auth.signUp(
          email: email,
          password: _password.text,
        );
        // If "Confirm email" is ON in Supabase there is no session yet.
        if (res.session == null && mounted) {
          showToast(
            context,
            'Check your email to confirm your account, then sign in.',
          );
          setState(() => _signUp = false);
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: _password.text,
        );
        // AuthGate reacts to the new session by itself.
      }
    } on AuthException catch (e) {
      if (mounted) showToast(context, e.message);
    } catch (_) {
      if (mounted) {
        showToast(
          context,
          'Something went wrong. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (!isValidEmail(email)) {
      showToast(context, 'Enter your email first, then tap Forgot password');
      return;
    }
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (mounted) showToast(context, 'Password reset link sent to $email');
    } on AuthException catch (e) {
      if (mounted) showToast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BayBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 12),
                    Semantics(
                      label: 'Glowing game controller wearing a crown',
                      child: const SizedBox(
                        height: 220,
                        child: CustomPaint(painter: _HeroPainter()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _Headline(),
                    const SizedBox(height: 22),

                    const _FieldLabel('Email'),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(
                        color: BayColors.text,
                        fontSize: 16,
                      ),
                      decoration: bayInputDecoration(hint: 'you@example.com'),
                      validator: (v) =>
                          isValidEmail(v ?? '') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 14),

                    const _FieldLabel('Password'),
                    TextFormField(
                      controller: _password,
                      obscureText: _hide,
                      style: const TextStyle(
                        color: BayColors.text,
                        fontSize: 16,
                      ),
                      decoration: bayInputDecoration(
                        hint: _signUp
                            ? 'At least 8 characters'
                            : 'Your password',
                        suffix: IconButton(
                          icon: Icon(
                            _hide
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: BayColors.muted,
                          ),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                      validator: (v) => (v ?? '').length >= 8
                          ? null
                          : 'Use at least 8 characters',
                    ),

                    if (_signUp) ...[
                      const SizedBox(height: 14),
                      const _FieldLabel('Confirm password'),
                      TextFormField(
                        controller: _confirm,
                        obscureText: _hide,
                        style: const TextStyle(
                          color: BayColors.text,
                          fontSize: 16,
                        ),
                        decoration: bayInputDecoration(
                          hint: 'Repeat your password',
                        ),
                        validator: (v) => v == _password.text
                            ? null
                            : 'Passwords do not match',
                      ),
                    ] else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgot,
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: BayColors.muted),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),

                    _GradientButton(
                      label: _signUp ? 'GET STARTED' : 'SIGN IN',
                      loading: _loading,
                      onTap: _submit,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() => _signUp = !_signUp),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: BayColors.text,
                        side: const BorderSide(color: BayColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(_signUp ? 'Sign in' : 'Create a new account'),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Free to play. Bay Coins cannot be withdrawn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: BayColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Logo and headline ─────────────────────────

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: const Size(40, 40), painter: _HexPainter()),
              Text('B', style: display(24, color: BayColors.neon, spacing: 0)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'BAYVER',
          style: display(
            28,
            color: BayColors.neon,
            spacing: 7,
            shadows: const [
              Shadow(color: Color.fromRGBO(47, 199, 116, .35), blurRadius: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      const TextSpan(
        text: 'YOUR SKILL FINALLY ',
        children: [
          TextSpan(
            text: 'COUNTS.',
            style: TextStyle(
              color: BayColors.neon,
              shadows: [
                Shadow(
                  color: Color.fromRGBO(47, 199, 116, .35),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: display(42, spacing: 2, height: 1.05),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [BayColors.neon, BayColors.lime],
        ),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(47, 199, 116, .30), blurRadius: 24),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: loading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: BayColors.ink,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: BayColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Painters ─────────────────────────

class _HexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 36;
    final path = Path()
      ..moveTo(18 * s, 2 * s)
      ..lineTo(32 * s, 10 * s)
      ..lineTo(32 * s, 26 * s)
      ..lineTo(18 * s, 34 * s)
      ..lineTo(4 * s, 26 * s)
      ..lineTo(4 * s, 10 * s)
      ..close();
    canvas.drawPath(path, Paint()..color = BayColors.card);
    canvas.drawPath(
      path,
      Paint()
        ..color = BayColors.neon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _HeroPainter extends CustomPainter {
  const _HeroPainter();

  static const _w = 342.0;
  static const _h = 250.0;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / _w, size.height / _h);
    canvas.save();
    canvas.translate((size.width - _w * s) / 2, (size.height - _h * s) / 2);
    canvas.scale(s);

    // Soft green glow behind everything.
    final glowRect = Rect.fromCenter(
      center: const Offset(171, 145),
      width: 330,
      height: 210,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color.fromRGBO(47, 199, 116, .30),
            Color.fromRGBO(47, 199, 116, 0),
          ],
        ).createShader(glowRect),
    );

    // Rings.
    canvas.drawCircle(
      const Offset(171, 145),
      96,
      Paint()
        ..color = const Color(0xFF1E4D33)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _dashedCircle(
      canvas,
      const Offset(171, 145),
      122,
      Paint()
        ..color = const Color(0xFF143B27)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      6,
      8,
    );

    // Controller body.
    final body = Path()
      ..moveTo(96, 128)
      ..cubicTo(96, 108, 112, 100, 130, 100)
      ..lineTo(212, 100)
      ..cubicTo(230, 100, 246, 108, 246, 128)
      ..lineTo(258, 186)
      ..cubicTo(262, 206, 244, 212, 232, 198)
      ..lineTo(214, 176)
      ..lineTo(128, 176)
      ..lineTo(110, 198)
      ..cubicTo(98, 212, 80, 206, 84, 186)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..color = BayColors.neon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(body, Paint()..color = BayColors.card);
    canvas.drawPath(
      body,
      Paint()
        ..color = BayColors.neon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    // D-pad.
    final dpad = Paint()
      ..color = BayColors.neon
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(122, 130), const Offset(142, 130), dpad);
    canvas.drawLine(const Offset(132, 120), const Offset(132, 140), dpad);

    // Buttons.
    canvas.drawCircle(
      const Offset(204, 124),
      6,
      Paint()..color = BayColors.gold,
    );
    canvas.drawCircle(
      const Offset(222, 138),
      6,
      Paint()..color = BayColors.neon,
    );
    canvas.drawCircle(
      const Offset(186, 138),
      6,
      Paint()..color = BayColors.orange,
    );
    canvas.drawCircle(
      const Offset(204, 152),
      6,
      Paint()..color = BayColors.blue,
    );

    // Crown.
    final crown = Path()
      ..moveTo(146, 84)
      ..lineTo(154, 56)
      ..lineTo(171, 74)
      ..lineTo(188, 56)
      ..lineTo(196, 84)
      ..close();
    canvas.drawPath(crown, Paint()..color = BayColors.gold);
    canvas.drawPath(
      crown,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // Floating chips.
    _chip(
      canvas,
      const Rect.fromLTWH(10, 52, 84, 30),
      '+35 BC',
      BayColors.gold,
    );
    _chip(
      canvas,
      const Rect.fromLTWH(248, 40, 84, 30),
      'RANK UP',
      BayColors.neon,
    );
    _chip(
      canvas,
      const Rect.fromLTWH(256, 200, 76, 30),
      '7 WINS',
      BayColors.orange,
    );

    canvas.restore();
  }

  void _dashedCircle(
    Canvas c,
    Offset center,
    double r,
    Paint p,
    double dash,
    double gap,
  ) {
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: r));
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        c.drawPath(m.extractPath(d, math.min(d + dash, m.length)), p);
        d += dash + gap;
      }
    }
  }

  void _chip(Canvas c, Rect r, String label, Color color) {
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(15));
    c.drawRRect(rr, Paint()..color = BayColors.card);
    c.drawRRect(
      rr,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      c,
      Offset(r.center.dx - tp.width / 2, r.center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═════════════════════════════════════════════════════════════
//  APP FLOW (read top to bottom):
//  AuthScreen (email + password) → AuthGate → ProfileGate → [Player Passport] → MainShell
//  MainShell tabs: Home · Matches · League · Clans · Clips
//  Home → Report result   |   Matches → Report result
// ═════════════════════════════════════════════════════════════

/// Short name for the colours used by the new screens.
typedef BC = BayColors;

/// Any screen can switch the bottom tab:      tabIndex.value = 1;
final tabIndex = ValueNotifier<int>(0);

/// Any screen can ask Home to reload:         homeRefresh.value++;
final homeRefresh = ValueNotifier<int>(0);

String initials(String s) =>
    s.isEmpty ? '?' : s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();

Future<void> signOut(BuildContext context) async {
  tabIndex.value = 0;
  await supabase.auth.signOut();
  if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
}

// ───────────────────────── ProfileGate ─────────────────────────
// Logged in but Player Passport incomplete? Show the passport form. Otherwise the app.

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});
  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<Map<String, dynamic>?> _future = _load();

  Future<Map<String, dynamic>?> _load() => supabase
      .from('profiles')
      .select('gamertag, phone, campus')
      .eq('id', supabase.auth.currentUser!.id)
      .maybeSingle();

  void _reload() => setState(() {
    _future = _load();
  });

  bool _filled(dynamic v) => v is String && v.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: BC.neon)),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Could not load your profile',
                    style: TextStyle(color: BC.orange),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _reload,
                    child: const Text('Try again'),
                  ),
                  TextButton(
                    onPressed: () => supabase.auth.signOut(),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          );
        }
        final p = snap.data;
        final complete =
            p != null &&
            _filled(p['gamertag']) &&
            _filled(p['phone']) &&
            _filled(p['campus']);
        return complete
            ? const MainShell()
            : PassportSetupScreen(onDone: _reload);
      },
    );
  }
}

// ───────────────────────── Player Passport setup ─────────────────────────

const _campuses = <(String, String)>[
  ('MMU', 'Multimedia University (MMU)'),
  ('UoN', 'University of Nairobi (UoN)'),
  ('KU', 'Kenyatta University (KU)'),
  ('JKUAT', 'JKUAT'),
  ('Strathmore', 'Strathmore University'),
  ('USIU', 'USIU-Africa'),
  ('Moi', 'Moi University'),
  ('Egerton', 'Egerton University'),
  ('Maseno', 'Maseno University'),
  ('Other', 'Other campus'),
];

class PassportSetupScreen extends StatefulWidget {
  const PassportSetupScreen({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<PassportSetupScreen> createState() => _PassportSetupScreenState();
}

class _PassportSetupScreenState extends State<PassportSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tag = TextEditingController();
  final _phone = TextEditingController();
  String? _campus; // code, e.g. 'MMU'
  String _game = 'eFootball';
  bool _loading = false;
  String? _campusError;

  @override
  void dispose() {
    _tag.dispose();
    _phone.dispose();
    super.dispose();
  }

  String get _campusLabel => _campuses
      .firstWhere(
        (c) => c.$1 == _campus,
        orElse: () => ('', 'Choose your campus'),
      )
      .$2;

  Future<void> _pickCampus() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: BC.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final c in _campuses)
              ListTile(
                title: Text(c.$2, style: const TextStyle(color: BC.text)),
                trailing: c.$1 == _campus
                    ? const Icon(Icons.check, color: BC.neon)
                    : null,
                onTap: () => Navigator.pop(ctx, c.$1),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _campus = picked;
        _campusError = null;
      });
    }
  }

  Future<void> _save() async {
    final okForm = _formKey.currentState!.validate();
    if (_campus == null) setState(() => _campusError = 'Choose your campus');
    if (!okForm || _campus == null) return;

    setState(() => _loading = true);
    try {
      await supabase
          .from('profiles')
          .update({
            'gamertag': _tag.text.trim(),
            'campus': _campus,
            'phone': normalizeKePhone(_phone.text),
            'main_game': _game,
          })
          .eq('id', supabase.auth.currentUser!.id);
      widget.onDone();
    } on PostgrestException catch (e) {
      if (mounted) {
        showToast(
          context,
          e.code == '23505'
              ? 'That gamertag is taken. Try another.'
              : e.message,
        );
      }
    } catch (_) {
      if (mounted) showToast(context, 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BayBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _Logo(),
                        const Spacer(),
                        TextButton(
                          onPressed: () => supabase.auth.signOut(),
                          child: const Text(
                            'Sign out',
                            style: TextStyle(color: BC.muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'SET UP YOUR PASSPORT',
                      style: display(30, spacing: 1.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This is how other players find and recognise you.',
                      style: TextStyle(color: BC.muted, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    const _FieldLabel('Gamertag'),
                    TextFormField(
                      controller: _tag,
                      maxLength: 16,
                      style: const TextStyle(color: BC.text),
                      decoration: bayInputDecoration(hint: 'e.g. Kamau_10'),
                      validator: (v) =>
                          RegExp(r'^[A-Za-z0-9_]{3,16}$')
                              .hasMatch((v ?? '').trim())
                          ? null
                          : '3-16 letters, numbers or underscore',
                    ),
                    const SizedBox(height: 12),

                    const _FieldLabel('Campus'),
                    InkWell(
                      onTap: _pickCampus,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: bayInputDecoration().copyWith(
                          errorText: _campusError,
                          suffixIcon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: BC.muted,
                          ),
                        ),
                        child: Text(
                          _campusLabel,
                          style: TextStyle(
                            color: _campus == null ? BC.muted : BC.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const _FieldLabel('Phone number'),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: BC.text),
                      decoration: bayInputDecoration(hint: '0712 345 678'),
                      validator: (v) => normalizeKePhone(v ?? '') != null
                          ? null
                          : 'Enter a valid Kenyan number',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Private. Never shown to other players.',
                        style: TextStyle(color: BC.muted, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const _FieldLabel('Main game'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final g in const [
                          'eFootball',
                          'PUBG Mobile',
                          'Both',
                        ])
                          ChoiceChip(
                            label: Text(g),
                            selected: _game == g,
                            onSelected: (_) => setState(() => _game = g),
                            selectedColor: BC.tint,
                            backgroundColor: BC.card,
                            side: BorderSide(
                              color: _game == g ? BC.neon : BC.border,
                            ),
                            labelStyle: TextStyle(
                              color: _game == g ? BC.neon : BC.text,
                              fontWeight: FontWeight.w600,
                            ),
                            showCheckmark: false,
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    _GradientButton(
                      label: 'CREATE PASSPORT',
                      onTap: _save,
                      loading: _loading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── MainShell (bottom navigation) ─────────────────────────

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = [
    HomeScreen(),
    MatchesScreen(),
    _Soon('League'),
    _Soon('Clans'),
    _Soon('Clips'),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, i, _) => Scaffold(
        backgroundColor: BC.bg,
        body: IndexedStack(index: i, children: _pages),
        bottomNavigationBar: NavigationBar(
          backgroundColor: BC.bg,
          indicatorColor: const Color(0xFF12301E),
          selectedIndex: i,
          onDestinationSelected: (v) {
            HapticFeedback.selectionClick();
            tabIndex.value = v;
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: BC.neon),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined),
              selectedIcon: Icon(Icons.sports_esports, color: BC.neon),
              label: 'Matches',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events, color: BC.neon),
              label: 'League',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map, color: BC.neon),
              label: 'Clans',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle, color: BC.neon),
              label: 'Clips',
            ),
          ],
        ),
      ),
    );
  }
}

class _Soon extends StatelessWidget {
  const _Soon(this.name);
  final String name;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
      child: Text(
        '$name coming next',
        style: const TextStyle(color: BC.muted, fontSize: 18),
      ),
    ),
  );
}

/// Placeholder for screens not built yet (Shop, Wallet, Pundit, Passport, ...)
class SubPage extends StatelessWidget {
  const SubPage(this.title, {super.key, this.showSignOut = false});
  final String title;
  final bool showSignOut;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BC.bg,
    appBar: AppBar(backgroundColor: BC.bg, title: Text(title.toUpperCase())),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$title coming next',
            style: const TextStyle(color: BC.muted, fontSize: 18),
          ),
          if (showSignOut) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => signOut(context),
              child: const Text('Sign out'),
            ),
          ],
        ],
      ),
    ),
  );
}

// ───────────────────────── HOME ─────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _future = _load();

  @override
  void initState() {
    super.initState();
    homeRefresh.addListener(_reload);
  }

  @override
  void dispose() {
    homeRefresh.removeListener(_reload);
    super.dispose();
  }

  Future<Map<String, dynamic>> _load() async {
    final r = await supabase.rpc('get_home');
    return Map<String, dynamic>.from(r as Map);
  }

  void _reload() {
    if (mounted) {
      setState(() {
        _future = _load();
      });
    }
  }

  void _go(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _openDrop() async {
    HapticFeedback.mediumImpact();
    try {
      final coins = await supabase.rpc('open_drop');
      if (mounted) showToast(context, 'Bay Drop: +$coins BC!');
      _reload();
    } catch (_) {
      if (mounted) showToast(context, 'Could not open drop');
    }
  }

  String _when(String iso) {
    final t = DateTime.parse(iso).toLocal();
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final mm = t.minute.toString().padLeft(2, '0');
    final ap = t.hour >= 12 ? 'PM' : 'AM';
    final n = DateTime.now();
    final today = t.year == n.year && t.month == n.month && t.day == n.day;
    return '${today ? 'Today' : '${t.day}/${t.month}'} $h:$mm $ap';
  }

  String _countdown(String iso) {
    final d = DateTime.parse(iso).toLocal().difference(DateTime.now());
    if (d.isNegative) return 'NOW';
    if (d.inMinutes < 60) return 'IN ${d.inMinutes} MIN';
    return 'IN ${d.inHours} HRS';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.1),
          radius: 1.2,
          colors: [Color(0xFF0F4A28), Color(0xFF06100C), BC.bg],
          stops: [0, .55, 1],
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: BC.neon),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load: ${snap.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: BC.orange),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _reload,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final d = snap.data!;
            final tag = (d['gamertag'] ?? 'Player') as String;
            final xp = d['xp'] as int;
            final goal = d['xp_goal'] as int;
            final streak = d['streak'] as int;
            final league = d['league'] as Map<String, dynamic>?;
            final next = d['next_match'] as Map<String, dynamic>?;
            final unread = d['unread'] as int;
            final drops = d['drops_ready'] as int;

            return RefreshIndicator(
              color: BC.neon,
              onRefresh: () async => _reload(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                children: [
                  // ── Top bar
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: BC.neon, width: 2),
                          borderRadius: BorderRadius.circular(10),
                          color: BC.card,
                        ),
                        child: const Text(
                          'B',
                          style: TextStyle(
                            color: BC.neon,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'BAYVER',
                          style: TextStyle(
                            color: BC.neon,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _go(const SubPage('Wallet')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: BC.card,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: const Color(0xFF6B5314)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: BC.gold,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${d['bay_coins']}',
                                style: const TextStyle(
                                  color: BC.gold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Badge(
                        isLabelVisible: unread > 0,
                        label: Text('$unread'),
                        backgroundColor: BC.orange,
                        child: IconButton.outlined(
                          onPressed: () => _go(const SubPage('Messages')),
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: BC.text,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Profile card
                  _HCard(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F2A1B),
                            border: Border.all(color: BC.neon, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x592FC774),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Text(
                            initials(tag),
                            style: const TextStyle(
                              color: BC.neon,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      tag.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: BC.text,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF12263F),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: BC.blue),
                                    ),
                                    child: Text(
                                      '${d['tier']}',
                                      style: const TextStyle(
                                        color: Color(0xFF8EC3FF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (xp / goal).clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFF06100C),
                                  color: BC.neon,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$xp / $goal XP to ${d['next_tier']}',
                                style: const TextStyle(
                                  color: BC.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Campus league
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BC.border),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3D22), BC.card],
                        stops: [0, .7],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CAMPUS LEAGUE',
                                style: TextStyle(
                                  color: BC.neon,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                league == null
                                    ? 'NO LEAGUE YET'
                                    : (league['name'] as String).toUpperCase(),
                                style: const TextStyle(
                                  color: BC.text,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                league == null
                                    ? 'Your campus league opens soon'
                                    : 'Season ${league['season']} · Week ${league['week']} of ${league['total_weeks']} · You are #${league['rank']}',
                                style: const TextStyle(
                                  color: BC.muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (league != null)
                                _SmallButton(
                                  'VIEW TABLE',
                                  () => _go(const SubPage('League table')),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.emoji_events,
                          color: BC.gold,
                          size: 84,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Streak
                  _HCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: BC.orange,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$streak DAY STREAK',
                                style: const TextStyle(
                                  color: BC.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12261B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${d['freezes']} freeze left',
                                style: const TextStyle(
                                  color: BC.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(7, (i) {
                            final filled = i < streak;
                            final isNext = i == streak;
                            return Expanded(
                              child: Container(
                                height: 8,
                                margin: EdgeInsets.only(right: i == 6 ? 0 : 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: filled ? BC.neon : Colors.transparent,
                                  border: isNext
                                      ? Border.all(color: BC.neon, width: 2)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Next match
                  _HCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (next == null)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'NO MATCH SCHEDULED',
                              style: TextStyle(
                                color: BC.muted,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'NEXT MATCH · ${_when(next['scheduled_at']).toUpperCase()}',
                                  style: const TextStyle(
                                    color: BC.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.circle,
                                color: BC.orange,
                                size: 8,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _countdown(next['scheduled_at']),
                                style: const TextStyle(
                                  color: BC.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'YOU '),
                                const TextSpan(
                                  text: 'VS',
                                  style: TextStyle(color: BC.neon),
                                ),
                                TextSpan(
                                  text:
                                      ' ${(next['opponent'] ?? 'Opponent').toString().toUpperCase()}',
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              color: BC.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        next == null
                            ? _GradientButton(
                                label: 'FIND A MATCH',
                                onTap: () => tabIndex.value = 1,
                              )
                            : _GradientButton(
                                label: 'REPORT RESULT',
                                onTap: () async {
                                  final changed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportResultScreen(
                                        matchId: next['id'] as String,
                                      ),
                                    ),
                                  );
                                  if (changed == true) _reload();
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Shortcut tiles
                  Row(
                    children: [
                      _Tile(
                        Icons.shopping_bag_outlined,
                        'Shop',
                        BC.neon,
                        () => _go(const SubPage('Shop')),
                      ),
                      const SizedBox(width: 8),
                      _Tile(
                        Icons.account_balance_wallet_outlined,
                        'Wallet',
                        BC.gold,
                        () => _go(const SubPage('Wallet')),
                      ),
                      const SizedBox(width: 8),
                      _Tile(
                        Icons.chat_outlined,
                        'Pundit',
                        BC.blue,
                        () => _go(const SubPage('Pundit')),
                      ),
                      const SizedBox(width: 8),
                      _Tile(
                        Icons.badge_outlined,
                        'Passport',
                        BC.orange,
                        () => _go(const SubPage('Passport', showSignOut: true)),
                      ),
                    ],
                  ),

                  // ── Bay Drop (only when the database says one is waiting)
                  if (drops > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BC.lime),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B2E0C), BC.card],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drops > 1
                                      ? 'BAY DROPS READY ($drops)'
                                      : 'BAY DROP READY',
                                  style: const TextStyle(
                                    color: BC.text,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Text(
                                  'Mystery coins for your last win',
                                  style: TextStyle(
                                    color: BC.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: _openDrop,
                            style: FilledButton.styleFrom(
                              backgroundColor: BC.lime,
                              foregroundColor: BC.ink,
                              minimumSize: const Size(84, 44),
                            ),
                            child: const Text(
                              'OPEN',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HCard extends StatelessWidget {
  const _HCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: BC.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF1E4D33)),
    ),
    child: child,
  );
}

class _SmallButton extends StatelessWidget {
  const _SmallButton(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [BC.neon, BC.lime]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: BC.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: BC.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E4D33)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: BC.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── MATCHES TAB ─────────────────────────

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() async {
    final uid = supabase.auth.currentUser!.id;
    final rows = List<Map<String, dynamic>>.from(
      await supabase
          .from('matches')
          .select()
          .or('player1.eq.$uid,player2.eq.$uid')
          .order('created_at', ascending: false),
    );
    if (rows.isEmpty) return rows;

    // Look up opponents' gamertags
    final ids = <String>{
      for (final m in rows) m['player1'] as String,
      for (final m in rows) m['player2'] as String,
    }.toList();
    final players = List<Map<String, dynamic>>.from(
      await supabase
          .from('public_players')
          .select('id, gamertag')
          .inFilter('id', ids),
    );
    final names = {
      for (final p in players)
        p['id'] as String: (p['gamertag'] ?? 'Player') as String,
    };
    for (final m in rows) {
      final oppId =
          (m['player1'] == uid ? m['player2'] : m['player1']) as String;
      m['opponent'] = names[oppId] ?? 'Player';
    }
    return rows;
  }

  void _reload() => setState(() {
    _future = _load();
  });

  Future<void> _challenge() async {
    final c = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BC.card,
        title: const Text(
          'Challenge a player',
          style: TextStyle(color: BC.text),
        ),
        content: TextField(
          controller: c,
          autofocus: true,
          style: const TextStyle(color: BC.text),
          decoration: bayInputDecoration(hint: 'Their gamertag'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: BC.neon,
              foregroundColor: BC.ink,
            ),
            child: const Text('Challenge'),
          ),
        ],
      ),
    );
    if (tag == null || tag.isEmpty) return;
    try {
      await supabase.rpc('challenge_player', params: {'p_gamertag': tag});
      if (!mounted) return;
      showToast(context, 'Match created with $tag');
      _reload();
      homeRefresh.value++;
    } on PostgrestException catch (e) {
      if (mounted) showToast(context, e.message);
    }
  }

  Color _statusColor(String s) => switch (s) {
    'scheduled' => BC.neon,
    'awaiting_confirmation' => BC.orange,
    'confirmed' => BC.blue,
    _ => BC.muted,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BC.bg,
      appBar: AppBar(
        backgroundColor: BC.bg,
        title: const Text(
          'MY MATCHES',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _challenge,
        backgroundColor: BC.neon,
        foregroundColor: BC.ink,
        icon: const Icon(Icons.sports_esports),
        label: const Text(
          'CHALLENGE',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: BC.neon),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: BC.orange),
              ),
            );
          }
          final matches = snap.data!;
          if (matches.isEmpty) {
            return const Center(
              child: Text(
                'No matches yet.\nTap CHALLENGE to play someone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: BC.muted),
              ),
            );
          }
          return RefreshIndicator(
            color: BC.neon,
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final m = matches[i];
                final status = m['status'] as String;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportResultScreen(matchId: m['id'] as String),
                      ),
                    );
                    if (changed == true) {
                      _reload();
                      homeRefresh.value++;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BC.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: BC.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOU VS ${(m['opponent'] as String).toUpperCase()}',
                                style: const TextStyle(
                                  color: BC.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${m['game']} · ${m['round']}',
                                style: const TextStyle(color: BC.muted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _statusColor(status)),
                          ),
                          child: Text(
                            status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── REPORT RESULT ─────────────────────────

class ReportResultScreen extends StatefulWidget {
  const ReportResultScreen({super.key, required this.matchId});
  final String matchId;
  @override
  State<ReportResultScreen> createState() => _ReportResultScreenState();
}

class _ReportResultScreenState extends State<ReportResultScreen> {
  Map<String, dynamic>? _match;
  String _myTag = 'You';
  String _oppTag = 'Opponent';
  bool _iAmP1 = true;
  int _mine = 0;
  int _theirs = 0;
  XFile? _shot;
  bool _busy = false;
  String? _error;

  String get _uid => supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final m = await supabase
          .from('matches')
          .select()
          .eq('id', widget.matchId)
          .single();
      final p1 = m['player1'] as String;
      final p2 = m['player2'] as String;
      final players = List<Map<String, dynamic>>.from(
        await supabase.from('public_players').select('id, gamertag').inFilter(
          'id',
          [p1, p2],
        ),
      );
      String tag(String id) {
        for (final p in players) {
          if (p['id'] == id) return (p['gamertag'] ?? 'Player') as String;
        }
        return 'Player';
      }

      _iAmP1 = p1 == _uid;
      _myTag = tag(_iAmP1 ? p1 : p2);
      _oppTag = tag(_iAmP1 ? p2 : p1);
      if (m['score1'] != null) {
        _mine = (_iAmP1 ? m['score1'] : m['score2']) as int;
        _theirs = (_iAmP1 ? m['score2'] : m['score1']) as int;
      }
      if (mounted) setState(() => _match = m);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _pickShot() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (x != null) setState(() => _shot = x);
  }

  Future<void> _run(Future<void> Function() job, String done) async {
    setState(() => _busy = true);
    try {
      await job();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      showToast(context, done);
      Navigator.pop(
        context,
        true,
      ); // Home / Matches reload when they see "true"
    } on PostgrestException catch (e) {
      if (mounted) showToast(context, e.message);
    } catch (e) {
      if (mounted) showToast(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() => _run(() async {
    if (_shot == null) throw 'Add your final score screenshot first';
    final path = '${widget.matchId}/$_uid.jpg';
    final bytes = await _shot!.readAsBytes();
    await supabase.storage
        .from('screenshots')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    await supabase.rpc(
      'submit_result',
      params: {
        'p_match': widget.matchId,
        'p_score1': _iAmP1 ? _mine : _theirs,
        'p_score2': _iAmP1 ? _theirs : _mine,
        'p_path': path,
      },
    );
  }, 'Result submitted. Waiting for $_oppTag');

  Future<void> _confirm() => _run(
    () => supabase.rpc('confirm_result', params: {'p_match': widget.matchId}),
    'Result confirmed',
  );

  Future<void> _dispute() => _run(
    () => supabase.rpc('dispute_result', params: {'p_match': widget.matchId}),
    'Problem reported. We will review it',
  );

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: BC.bg,
        appBar: AppBar(backgroundColor: BC.bg),
        body: Center(
          child: Text(_error!, style: const TextStyle(color: BC.orange)),
        ),
      );
    }
    if (_match == null) {
      return const Scaffold(
        backgroundColor: BC.bg,
        body: Center(child: CircularProgressIndicator(color: BC.neon)),
      );
    }

    final status = _match!['status'] as String;
    final canReport = status == 'scheduled';
    final canConfirm =
        status == 'awaiting_confirmation' && _match!['reported_by'] != _uid;
    final reward = _match!['reward_bc'];
    final result = _mine > _theirs
        ? 'YOU WON · +$reward BC'
        : _mine < _theirs
        ? 'YOU LOST'
        : 'DRAW';

    return Scaffold(
      backgroundColor: BC.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.1),
            radius: 1.2,
            colors: [Color(0xFF0F4A28), Color(0xFF06100C), BC.bg],
            stops: [0, .55, 1],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: BC.text),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'REPORT RESULT',
                    style: TextStyle(
                      color: BC.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  '${_match!['game']} · ${_match!['round']}',
                  style: const TextStyle(color: BC.muted),
                ),
              ),
              const SizedBox(height: 14),

              // Score card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: BC.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E4D33)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Player(tag: _myTag, color: BC.neon),
                        Text(
                          '$_mine:$_theirs',
                          style: const TextStyle(
                            color: BC.text,
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Color(0x592FC774), blurRadius: 12),
                            ],
                          ),
                        ),
                        _Player(tag: _oppTag, color: BC.orange),
                      ],
                    ),
                    if (canReport) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Stepper(
                            value: _mine,
                            onChanged: (v) => setState(() => _mine = v),
                          ),
                          _Stepper(
                            value: _theirs,
                            onChanged: (v) => setState(() => _theirs = v),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12301E),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: BC.neon),
                      ),
                      child: Text(
                        result,
                        style: const TextStyle(
                          color: BC.neon,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Screenshot (only while reporting)
              if (canReport)
                InkWell(
                  onTap: _pickShot,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: BC.border),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _shot == null
                                ? Icons.add_photo_alternate_outlined
                                : Icons.check_circle,
                            color: BC.neon,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _shot == null
                                ? 'Add final score screenshot'
                                : 'Screenshot added · tap to replace',
                            style: const TextStyle(
                              color: BC.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 14),

              // Steps follow the real status from the database
              const _Step(
                n: 1,
                text: 'You submit the score and screenshot',
                on: true,
              ),
              _Step(
                n: 2,
                text: '$_oppTag confirms within 24 hours',
                on: status != 'scheduled',
                orange: true,
              ),
              _Step(
                n: 3,
                text: 'Rank, coins and streak update',
                on: status == 'confirmed',
              ),
              const SizedBox(height: 18),

              if (canReport)
                _GradientButton(
                  label: 'SUBMIT RESULT',
                  onTap: _submit,
                  loading: _busy,
                ),
              if (canConfirm)
                _GradientButton(
                  label: 'CONFIRM RESULT',
                  onTap: _confirm,
                  loading: _busy,
                ),
              if (!canReport && !canConfirm)
                Center(
                  child: Text(
                    'Status: ${status.replaceAll('_', ' ')}${status == 'awaiting_confirmation' ? ' (waiting for $_oppTag)' : ''}',
                    style: const TextStyle(color: BC.muted),
                  ),
                ),
              const SizedBox(height: 10),
              if (status == 'scheduled' || status == 'awaiting_confirmation')
                OutlinedButton(
                  onPressed: _busy ? null : _dispute,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: BC.border),
                    foregroundColor: BC.text,
                  ),
                  child: const Text('Report a problem'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({required this.tag, required this.color});
  final String tag;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          color: color.withAlpha(30),
        ),
        child: Text(
          initials(tag),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        width: 90,
        child: Text(
          tag,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: BC.text,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: value > 0 ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove_circle_outline, color: BC.muted),
      ),
      IconButton(
        onPressed: value < 30 ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add_circle, color: BC.neon),
      ),
    ],
  );
}

class _Step extends StatelessWidget {
  const _Step({
    required this.n,
    required this.text,
    this.on = false,
    this.orange = false,
  });
  final int n;
  final String text;
  final bool on;
  final bool orange;
  @override
  Widget build(BuildContext context) {
    final c = on ? (orange ? BC.orange : BC.neon) : BC.muted;
    final filled = on && !orange;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? BC.neon : Colors.transparent,
              border: Border.all(color: c, width: 2),
            ),
            child: Text(
              '$n',
              style: TextStyle(
                color: filled ? BC.ink : c,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: on ? BC.text : BC.muted)),
          ),
        ],
      ),
    );
  }
}
