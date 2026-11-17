import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// 1. SUPABASE CONFIGURATION
// ============================================================
//
// Paste your Supabase URL and anon/publishable key below.
//
// Alternatively, run:
// flutter run --dart-define=SUPABASE_URL=YOUR_URL
// --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
//
// NEVER put your Supabase service_role key in Flutter.
//

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://https://trnxatkltzzrrhszctyq.supabase.co',
);

const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_Qg3FRNBIAx5-AVQS-ghb-A_v4koi3fp',
);

bool get _isSupabaseConfigured {
  return _supabaseUrl.startsWith('https://') &&
      !_supabaseUrl.contains('YOUR_PROJECT_ID') &&
      _supabaseAnonKey.isNotEmpty &&
      !_supabaseAnonKey.contains('YOUR_ANON_KEY');
}

SupabaseClient get supabase => Supabase.instance.client;

// ============================================================
// 2. APPLICATION ENTRY POINT
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configured = _isSupabaseConfigured;

  if (configured) {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }

  runApp(BayverApp(supabaseConfigured: configured));
}

// ============================================================
// 3. BAYVER COLOURS
// ============================================================

class BayColors {
  static const bg = Color(0xFF050A08);
  static const card = Color(0xFF0C1512);
  static const cardLight = Color(0xFF101F17);

  static const neon = Color(0xFF3DFF7A);
  static const lime = Color(0xFFB8F23A);

  static const gold = Color(0xFFFFC933);
  static const orange = Color(0xFFFF8A3D);
  static const blue = Color(0xFF4DA3FF);

  static const border = Color(0xFF2E7A52);

  static const text = Color(0xFFEAF7EF);
  static const muted = Color(0xFF9DB5A8);

  static const ink = Color(0xFF04110A);
}

// ============================================================
// 4. MAIN APPLICATION
// ============================================================

class BayverApp extends StatelessWidget {
  const BayverApp({super.key, required this.supabaseConfigured});

  final bool supabaseConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BAYVER',

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: BayColors.bg,
        primaryColor: BayColors.neon,
        colorScheme: const ColorScheme.dark(
          primary: BayColors.neon,
          secondary: BayColors.lime,
          surface: BayColors.card,
          error: BayColors.orange,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: BayColors.cardLight,
          contentTextStyle: TextStyle(color: BayColors.text),
        ),
      ),

      home: supabaseConfigured ? const AuthGate() : const SetupRequiredScreen(),
    );
  }
}

// ============================================================
// 5. CONFIGURATION SCREEN
// ============================================================

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BayColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Logo(),

                const SizedBox(height: 35),

                const Icon(
                  Icons.settings_rounded,
                  size: 55,
                  color: BayColors.neon,
                ),

                const SizedBox(height: 20),

                const Text(
                  'CONNECT SUPABASE',
                  style: TextStyle(
                    color: BayColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Add your Supabase project URL and anon key '
                  'inside main.dart before starting BAYVER.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BayColors.muted, height: 1.6),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BayColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BayColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHERE TO FIND YOUR KEYS',
                        style: TextStyle(
                          color: BayColors.neon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Supabase Dashboard → Project Settings → API',
                        style: TextStyle(color: BayColors.text),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Copy Project URL and anon/public key.',
                        style: TextStyle(color: BayColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 6. GENERAL HELPERS
// ============================================================

// 0712345678 -> +254712345678
// 0112345678 -> +254112345678

String toE164(String local) {
  return '+254${local.substring(1)}';
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
}

InputDecoration bayInputDecoration({String? hint, Widget? suffixIcon}) {
  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: BayColors.muted),

    filled: true,
    fillColor: BayColors.card,

    suffixIcon: suffixIcon,

    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),

    border: border(BayColors.border),
    enabledBorder: border(BayColors.border),
    focusedBorder: border(BayColors.neon),
    errorBorder: border(BayColors.orange),
    focusedErrorBorder: border(BayColors.orange),

    errorStyle: const TextStyle(color: BayColors.orange),
  );
}

// ============================================================
// 7. FIELD LABEL
// ============================================================

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
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
}

// ============================================================
// 8. BACKGROUND
// ============================================================

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

// ============================================================
// 9. AUTHENTICATION GATE
// ============================================================
//
// Signed out  -> WelcomeScreen
// Signed in   -> HomeScreen
//
// Supabase remembers the session, so the user does not need
// to enter their phone number every time they open the app.
//

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,

      builder: (context, snapshot) {
        final session = snapshot.hasData
            ? snapshot.data!.session
            : supabase.auth.currentSession;

        if (session == null) {
          return const WelcomeScreen();
        }

        return const HomeScreen();
      },
    );
  }
}

// ============================================================
// 10. WELCOME / SIGN UP / SIGN IN SCREEN
// ============================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const List<String> _campuses = [
    'Multimedia University of Kenya (MMU)',
    'University of Nairobi',
    'Kenyatta University',
    'Jomo Kenyatta University of Agriculture and Technology',
    'Strathmore University',
    'Other campus',
  ];

  final _formKey = GlobalKey<FormState>();

  final _phone = TextEditingController();

  String _campus = _campuses.first;

  bool _signInMode = false;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final ok = RegExp(r'^(07|01)\d{8}$').hasMatch(value ?? '');

    if (!ok) {
      return 'Enter a valid number, e.g. 0712345678';
    }

    return null;
  }

  // ----------------------------------------------------------
  // SEND OTP
  // ----------------------------------------------------------

  Future<void> _submit() async {
    if (_loading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    final phone = toE164(_phone.text.trim());

    try {
      await supabase.auth.signInWithOtp(
        phone: phone,

        // True for registration.
        // False for existing account sign in.
        shouldCreateUser: !_signInMode,

        // Campus is saved as authentication metadata.
        // SQL trigger uses this when creating the profile.
        data: _signInMode ? null : {'campus': _campus},
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              OtpScreen(phone: phone, campus: _campus, signInMode: _signInMode),
        ),
      );
    } on AuthException catch (error) {
      if (mounted) {
        showToast(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        showToast(
          context,
          'Something went wrong. Check your internet connection.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BayBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 25),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Logo(),

                const SizedBox(height: 8),

                const SizedBox(
                  height: 235,
                  child: CustomPaint(painter: _HeroPainter()),
                ),

                const SizedBox(height: 5),

                const _Headline(),

                const SizedBox(height: 23),

                // PHONE NUMBER
                const _FieldLabel('Phone number'),

                TextFormField(
                  controller: _phone,

                  keyboardType: TextInputType.phone,

                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],

                  style: const TextStyle(color: BayColors.text, fontSize: 16),

                  decoration: bayInputDecoration(hint: '07XX XXX XXX'),

                  validator: _validatePhone,
                ),

                // CAMPUS SELECTION
                if (!_signInMode) ...[
                  const SizedBox(height: 15),

                  const _FieldLabel('Your campus'),

                  DropdownButtonFormField<String>(
                    initialValue: _campus,
                    isExpanded: true,

                    dropdownColor: BayColors.card,

                    style: const TextStyle(color: BayColors.text, fontSize: 15),

                    decoration: bayInputDecoration(),

                    items: [
                      for (final campus in _campuses)
                        DropdownMenuItem(
                          value: campus,
                          child: Text(campus, overflow: TextOverflow.ellipsis),
                        ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _campus = value);
                      }
                    },
                  ),
                ],

                const SizedBox(height: 18),

                // PRIMARY BUTTON
                _GradientButton(
                  label: _signInMode ? 'SIGN IN' : 'GET STARTED',
                  loading: _loading,
                  onTap: _submit,
                ),

                const SizedBox(height: 12),

                // SWITCH BETWEEN SIGN IN AND SIGN UP
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _signInMode = !_signInMode;
                          });
                        },

                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),

                    foregroundColor: BayColors.text,

                    side: const BorderSide(color: BayColors.border),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: Text(_signInMode ? 'Create a new account' : 'Sign in'),
                ),

                const SizedBox(height: 14),

                const Text(
                  'One-time code by SMS. Free to play. '
                  'Bay Coins cannot be withdrawn.',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: BayColors.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 11. OTP VERIFICATION SCREEN
// ============================================================

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.campus,
    required this.signInMode,
  });

  final String phone;
  final String campus;
  final bool signInMode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();

  bool _loading = false;

  int _cooldown = 30;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // RESEND TIMER
  // ----------------------------------------------------------

  void _startCooldown() {
    _cooldown = 30;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_cooldown <= 1) {
        setState(() => _cooldown = 0);
        timer.cancel();
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  // ----------------------------------------------------------
  // VERIFY OTP
  // ----------------------------------------------------------

  Future<void> _verify() async {
    final code = _code.text.trim();

    if (_loading) return;

    if (code.length != 6) {
      showToast(context, 'Enter the 6-digit code.');
      return;
    }

    setState(() => _loading = true);

    try {
      await supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: widget.phone,
        token: code,
      );

      if (!mounted) return;

      // The AuthGate detects the new session.
      // It changes from WelcomeScreen to HomeScreen.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (error) {
      if (mounted) {
        showToast(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        showToast(context, 'Verification failed. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ----------------------------------------------------------
  // RESEND OTP
  // ----------------------------------------------------------

  Future<void> _resend() async {
    if (_loading || _cooldown > 0) return;

    setState(() => _loading = true);

    try {
      await supabase.auth.signInWithOtp(
        phone: widget.phone,

        shouldCreateUser: !widget.signInMode,

        data: widget.signInMode ? null : {'campus': widget.campus},
      );

      if (!mounted) return;

      setState(_startCooldown);

      showToast(context, 'New verification code sent.');
    } on AuthException catch (error) {
      if (mounted) {
        showToast(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        showToast(context, 'Could not resend the code.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BayBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,

                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: BayColors.text),
                ),
              ),

              const SizedBox(height: 14),

              const _Logo(),

              const SizedBox(height: 38),

              const Text(
                'ENTER YOUR CODE',

                style: TextStyle(
                  color: BayColors.text,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'We sent a 6-digit code to ${widget.phone}',

                style: const TextStyle(color: BayColors.muted, fontSize: 14),
              ),

              const SizedBox(height: 28),

              TextField(
                controller: _code,

                autofocus: true,

                keyboardType: TextInputType.number,

                textAlign: TextAlign.center,

                autofillHints: const [AutofillHints.oneTimeCode],

                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],

                style: const TextStyle(
                  color: BayColors.neon,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                ),

                decoration: bayInputDecoration(hint: '······'),

                onChanged: (value) {
                  if (value.length == 6) {
                    _verify();
                  }
                },
              ),

              const SizedBox(height: 20),

              _GradientButton(
                label: 'VERIFY',
                loading: _loading,
                onTap: _verify,
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: _cooldown > 0 || _loading ? null : _resend,

                child: Text(
                  _cooldown > 0
                      ? 'Resend code in ${_cooldown}s'
                      : 'Resend code',

                  style: TextStyle(
                    color: _cooldown > 0 ? BayColors.muted : BayColors.neon,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 12. PLAYER PROFILE MODEL
// ============================================================

class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.phone,
    required this.campus,
    required this.gamertag,
    required this.bayCoins,
    required this.xp,
    required this.wins,
    required this.streakDays,
    required this.freezeLeft,
    required this.rankTitle,
  });

  final String id;
  final String phone;
  final String campus;
  final String gamertag;

  final int bayCoins;
  final int xp;
  final int wins;
  final int streakDays;
  final int freezeLeft;

  final String rankTitle;

  factory PlayerProfile.fromMap(Map<String, dynamic> data, User user) {
    final userId = user.id;

    final fallbackGamertag = 'PLAYER_${userId.substring(0, 6).toUpperCase()}';

    return PlayerProfile(
      id: userId,

      phone: (data['phone'] ?? user.phone ?? '').toString(),

      campus: (data['campus'] ?? 'Other campus').toString(),

      gamertag: (data['gamertag'] ?? fallbackGamertag).toString(),

      bayCoins: (data['bay_coins'] as num?)?.toInt() ?? 0,

      xp: (data['xp'] as num?)?.toInt() ?? 0,

      wins: (data['wins'] as num?)?.toInt() ?? 0,

      streakDays: (data['streak_days'] as num?)?.toInt() ?? 0,

      freezeLeft: (data['freeze_left'] as num?)?.toInt() ?? 1,

      rankTitle: (data['rank_title'] ?? 'BRONZE I').toString(),
    );
  }
}

// ============================================================
// 13. HOME SCREEN
// ============================================================
//
// This is the main signed-in application shell.
//
// Navigation:
// 0 Home
// 1 Matches
// 2 League
// 3 Clans
// 4 Clips
//
// It loads the current user's Supabase profile.
//

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  late Future<PlayerProfile> _profileFuture;

  @override
  void initState() {
    super.initState();

    _profileFuture = _loadProfile();
  }

  // ----------------------------------------------------------
  // LOAD PLAYER PROFILE
  // ----------------------------------------------------------

  Future<PlayerProfile> _loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      throw Exception(
        'Your player profile was not found. '
        'Check that the Supabase profile trigger has been created.',
      );
    }

    return PlayerProfile.fromMap(data, user);
  }

  // ----------------------------------------------------------
  // REFRESH PROFILE
  // ----------------------------------------------------------

  Future<void> _refreshProfile() async {
    final newFuture = _loadProfile();

    setState(() {
      _profileFuture = newFuture;
    });

    await newFuture;
  }

  // ----------------------------------------------------------
  // BOTTOM NAVIGATION
  // ----------------------------------------------------------

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  // ----------------------------------------------------------
  // OPEN OTHER FEATURES
  // ----------------------------------------------------------

  void _openFeature(String title, IconData icon, String description) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FeaturePreviewScreen(
          title: title,
          icon: icon,
          description: description,
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,

      backgroundColor: BayColors.card,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (context) {
        return const Padding(
          padding: EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NOTIFICATIONS',

                style: TextStyle(
                  color: BayColors.neon,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 18),

              Text(
                'You are all caught up.',

                style: TextStyle(color: BayColors.text, fontSize: 16),
              ),

              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BayColors.bg,

      body: _BayBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _selectedTab,

            children: [
              // HOME

              _HomeDashboard(
                profileFuture: _profileFuture,
                onRefresh: _refreshProfile,
                onFindMatch: () => _changeTab(1),
                onOpenLeague: () => _changeTab(2),
                onOpenFeature: _openFeature,
                onNotifications: _showNotifications,
                onSignOut: () async {
                  await supabase.auth.signOut();

                  if (mounted) {
                    setState(() => _selectedTab = 0);
                  }
                },
              ),

              // MATCHES
              const _SecondaryTabScreen(
                title: 'MATCHES',
                subtitle: 'Find your next opponent.',
                icon: Icons.sports_esports_rounded,
                description:
                    'Your match history and free-to-play '
                    'matchmaking experience will appear here.',
              ),

              // LEAGUE
              const _SecondaryTabScreen(
                title: 'CAMPUS LEAGUE',
                subtitle: 'Represent your campus.',
                icon: Icons.emoji_events_rounded,
                description:
                    'Campus standings, seasonal rankings '
                    'and player performance will appear here.',
              ),

              // CLANS
              const _SecondaryTabScreen(
                title: 'CLANS',
                subtitle: 'Build your gaming community.',
                icon: Icons.groups_rounded,
                description:
                    'Create a clan, find players and follow '
                    'your campus community.',
              ),

              // CLIPS
              const _SecondaryTabScreen(
                title: 'CLIPS',
                subtitle: 'Share your best moments.',
                icon: Icons.play_circle_outline_rounded,
                description:
                    'Gameplay highlights and community '
                    'videos will appear here.',
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _BayBottomNavigation(
        selectedIndex: _selectedTab,
        onTap: _changeTab,
      ),
    );
  }
}

// ============================================================
// 14. HOME DASHBOARD
// ============================================================

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({
    required this.profileFuture,
    required this.onRefresh,
    required this.onFindMatch,
    required this.onOpenLeague,
    required this.onOpenFeature,
    required this.onNotifications,
    required this.onSignOut,
  });

  final Future<PlayerProfile> profileFuture;

  final Future<void> Function() onRefresh;

  final VoidCallback onFindMatch;
  final VoidCallback onOpenLeague;

  final void Function(String title, IconData icon, String description)
  onOpenFeature;

  final VoidCallback onNotifications;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerProfile>(
      future: profileFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: BayColors.neon),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _ProfileErrorView(
            error: snapshot.error?.toString() ?? 'Could not load your profile.',
            onRetry: onRefresh,
          );
        }

        final profile = snapshot.data!;

        return RefreshIndicator(
          onRefresh: onRefresh,

          color: BayColors.neon,
          backgroundColor: BayColors.card,

          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),

            children: [
              // HEADER

              _HomeHeader(
                coins: profile.bayCoins,
                onNotifications: onNotifications,
                onSignOut: onSignOut,
              ),

              const SizedBox(height: 15),

              // PLAYER PROFILE CARD
              _PlayerCard(profile: profile),

              const SizedBox(height: 10),

              // CAMPUS LEAGUE
              _CampusLeagueCard(campus: profile.campus, onTap: onOpenLeague),

              const SizedBox(height: 10),

              // STREAK
              _StreakCard(
                streakDays: profile.streakDays,
                freezeLeft: profile.freezeLeft,
              ),

              const SizedBox(height: 10),

              // NEXT MATCH
              _NextMatchCard(onFindMatch: onFindMatch),

              const SizedBox(height: 10),

              // QUICK ACTIONS
              _QuickActions(onOpenFeature: onOpenFeature),

              const SizedBox(height: 10),

              // BAY DROP
              _BayDropCard(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const _BayDropDialog(),
                  );
                },
              ),

              const SizedBox(height: 22),

              const Text(
                'BAYVER  •  YOUR SKILL COUNTS',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: BayColors.muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 15. HOME HEADER
// ============================================================

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.coins,
    required this.onNotifications,
    required this.onSignOut,
  });

  final int coins;

  final VoidCallback onNotifications;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _Logo(compact: true)),

        // BAY COINS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),

          decoration: BoxDecoration(
            color: BayColors.card,
            border: Border.all(color: const Color(0xFF9C7108)),
            borderRadius: BorderRadius.circular(30),
          ),

          child: Row(
            children: [
              const Icon(
                Icons.monetization_on,
                size: 20,
                color: BayColors.gold,
              ),

              const SizedBox(width: 7),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: coins.toDouble()),

                duration: const Duration(milliseconds: 900),

                builder: (context, value, _) {
                  return Text(
                    value.round().toString(),

                    style: const TextStyle(
                      color: BayColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: 9),

        // NOTIFICATIONS
        Container(
          width: 44,
          height: 44,

          decoration: BoxDecoration(
            color: BayColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: BayColors.border),
          ),

          child: IconButton(
            onPressed: onNotifications,

            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: BayColors.text,
              size: 21,
            ),
          ),
        ),

        const SizedBox(width: 4),

        // SIGN OUT
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: BayColors.muted),

          color: BayColors.card,

          onSelected: (value) {
            if (value == 'logout') {
              onSignOut();
            }
          },

          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: BayColors.orange, size: 19),
                  SizedBox(width: 10),
                  Text('Sign out'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// 16. PLAYER PROFILE CARD
// ============================================================

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final xpProgress = profile.xp % 500;

    final progress = xpProgress / 500;

    final initials = profile.gamertag.length >= 2
        ? profile.gamertag.substring(0, 2).toUpperCase()
        : profile.gamertag.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: BayColors.card,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: BayColors.border.withValues(alpha: 0.7)),

        boxShadow: [
          BoxShadow(
            color: BayColors.neon.withValues(alpha: 0.05),
            blurRadius: 18,
          ),
        ],
      ),

      child: Row(
        children: [
          // PROFILE AVATAR

          Container(
            width: 64,
            height: 64,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BayColors.cardLight,

              border: Border.all(color: BayColors.neon, width: 3),

              boxShadow: [
                BoxShadow(
                  color: BayColors.neon.withValues(alpha: 0.25),
                  blurRadius: 14,
                ),
              ],
            ),

            child: Center(
              child: Text(
                initials,

                style: const TextStyle(
                  color: BayColors.neon,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // PLAYER INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.gamertag,

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: BayColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),

                      decoration: BoxDecoration(
                        color: BayColors.blue.withValues(alpha: 0.12),

                        border: Border.all(color: BayColors.blue),

                        borderRadius: BorderRadius.circular(5),
                      ),

                      child: Text(
                        profile.rankTitle,

                        style: const TextStyle(
                          color: BayColors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                // XP BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),

                    duration: const Duration(milliseconds: 1200),

                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,

                        backgroundColor: BayColors.bg,

                        valueColor: const AlwaysStoppedAnimation<Color>(
                          BayColors.lime,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$xpProgress / 500 XP to next rank',

                  style: const TextStyle(color: BayColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 17. CAMPUS LEAGUE CARD
// ============================================================

class _CampusLeagueCard extends StatelessWidget {
  const _CampusLeagueCard({required this.campus, required this.onTap});

  final String campus;
  final VoidCallback onTap;

  String get campusEdition {
    if (campus.toLowerCase().contains('multimedia')) {
      return 'MMU EDITION';
    }

    if (campus.toLowerCase().contains('nairobi')) {
      return 'UON EDITION';
    }

    if (campus.toLowerCase().contains('kenyatta')) {
      return 'KU EDITION';
    }

    return 'CAMPUS LEAGUE';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: BayColors.cardLight,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: const Color(0xFF247849)),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Color(0xFF102B1B), BayColors.card],
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
                    color: BayColors.neon,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  campusEdition,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: BayColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Represent your campus and climb the leaderboard.',

                  maxLines: 2,

                  style: TextStyle(
                    color: BayColors.muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 13),

                _GradientButton(
                  label: 'VIEW TABLE',
                  onTap: onTap,
                  height: 43,
                  fontSize: 13,
                  compact: true,
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          const Icon(
            Icons.emoji_events_rounded,
            color: BayColors.gold,
            size: 82,
            shadows: [Shadow(color: BayColors.gold, blurRadius: 20)],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 18. STREAK CARD
// ============================================================

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streakDays, required this.freezeLeft});

  final int streakDays;
  final int freezeLeft;

  @override
  Widget build(BuildContext context) {
    final completedDays = streakDays.clamp(0, 7);

    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: BayColors.card,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(color: BayColors.border.withValues(alpha: 0.6)),
      ),

      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: BayColors.orange,
                size: 20,
              ),

              const SizedBox(width: 6),

              Text(
                '$streakDays DAY STREAK',

                style: const TextStyle(
                  color: BayColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),

              const Spacer(),

              Text(
                '$freezeLeft freeze left',

                style: const TextStyle(color: BayColors.muted, fontSize: 10),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: List.generate(7, (index) {
              final completed = index < completedDays;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),

                  height: 7,

                  margin: EdgeInsets.only(right: index == 6 ? 0 : 5),

                  decoration: BoxDecoration(
                    color: completed ? BayColors.neon : const Color(0xFF183324),

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: completed
                        ? [
                            BoxShadow(
                              color: BayColors.neon.withValues(alpha: 0.25),
                              blurRadius: 7,
                            ),
                          ]
                        : [],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 19. NEXT MATCH CARD
// ============================================================

class _NextMatchCard extends StatelessWidget {
  const _NextMatchCard({required this.onFindMatch});

  final VoidCallback onFindMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: BayColors.card,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: BayColors.border.withValues(alpha: 0.7)),

        boxShadow: [
          BoxShadow(
            color: BayColors.neon.withValues(alpha: 0.04),
            blurRadius: 18,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'NEXT MATCH',

                  style: TextStyle(
                    color: BayColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),

              Container(
                width: 8,
                height: 8,

                decoration: const BoxDecoration(
                  color: BayColors.orange,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              const Text(
                'NO MATCH SCHEDULED',

                style: TextStyle(
                  color: BayColors.orange,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'READY TO COMPETE?',

            style: TextStyle(
              color: BayColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Your next match will appear here when matchmaking is available.',

            style: TextStyle(color: BayColors.muted, fontSize: 11, height: 1.4),
          ),

          const SizedBox(height: 13),

          _GradientButton(
            label: 'FIND A MATCH',
            onTap: onFindMatch,
            height: 50,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 20. QUICK ACTIONS
// ============================================================

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onOpenFeature});

  final void Function(String title, IconData icon, String description)
  onOpenFeature;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickActionData(
        title: 'Shop',
        icon: Icons.shopping_bag_outlined,
        color: BayColors.neon,
        description: 'Explore the BAYVER shop.',
      ),
      _QuickActionData(
        title: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        color: BayColors.gold,
        description: 'View your in-app Bay Coin balance.',
      ),
      _QuickActionData(
        title: 'Pundit',
        icon: Icons.chat_bubble_outline,
        color: BayColors.blue,
        description: 'Join gaming discussions and predictions.',
      ),
      _QuickActionData(
        title: 'Passport',
        icon: Icons.contact_page_outlined,
        color: BayColors.orange,
        description: 'View your player profile and achievements.',
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: _QuickActionTile(
              data: items[i],

              onTap: () {
                onOpenFeature(
                  items[i].title,
                  items[i].icon,
                  items[i].description,
                );
              },
            ),
          ),

          if (i != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String description;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data, required this.onTap});

  final _QuickActionData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BayColors.card,

      borderRadius: BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(17),

        child: Container(
          height: 76,

          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),

            border: Border.all(color: BayColors.border.withValues(alpha: 0.6)),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, color: data.color, size: 22),

              const SizedBox(height: 7),

              Text(
                data.title,

                maxLines: 1,

                style: const TextStyle(
                  color: BayColors.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 21. BAY DROP CARD
// ============================================================

class _BayDropCard extends StatelessWidget {
  const _BayDropCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF17230D),

      borderRadius: BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(17),

        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),

            border: Border.all(color: BayColors.lime),

            boxShadow: [
              BoxShadow(
                color: BayColors.lime.withValues(alpha: 0.12),
                blurRadius: 15,
              ),
            ],
          ),

          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BAY DROP',

                      style: TextStyle(
                        color: BayColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Player rewards and achievements',

                      style: TextStyle(color: BayColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 11,
                ),

                decoration: BoxDecoration(
                  color: BayColors.lime,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Text(
                  'OPEN',

                  style: TextStyle(
                    color: BayColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 22. BAY DROP DIALOG
// ============================================================

class _BayDropDialog extends StatelessWidget {
  const _BayDropDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BayColors.card,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: BayColors.lime),
      ),

      child: Padding(
        padding: const EdgeInsets.all(22),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.card_giftcard_rounded,
              color: BayColors.lime,
              size: 55,
            ),

            const SizedBox(height: 15),

            const Text(
              'BAY DROP',

              style: TextStyle(
                color: BayColors.neon,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Player rewards and achievements are being prepared. '
              'You will see available rewards here when the feature is launched.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: BayColors.muted,
                height: 1.5,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            _GradientButton(
              label: 'GOT IT',
              onTap: () => Navigator.pop(context),
              height: 45,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 23. BOTTOM NAVIGATION
// ============================================================

class _BayBottomNavigation extends StatelessWidget {
  const _BayBottomNavigation({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const List<_NavData> _items = [
    _NavData('Home', Icons.home_rounded),
    _NavData('Matches', Icons.sports_esports_rounded),
    _NavData('League', Icons.emoji_events_outlined),
    _NavData('Clans', Icons.map_outlined),
    _NavData('Clips', Icons.play_circle_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BayColors.bg,

        border: Border(
          top: BorderSide(color: BayColors.border.withValues(alpha: 0.45)),
        ),
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 65,

          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    data: _items[i],
                    selected: selectedIndex == i,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavData {
  const _NavData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _NavData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? BayColors.neon : BayColors.muted;

    return InkWell(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: const EdgeInsets.symmetric(vertical: 7),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              data.icon,

              size: 22,
              color: color,

              shadows: selected
                  ? [const Shadow(color: BayColors.neon, blurRadius: 12)]
                  : [],
            ),

            const SizedBox(height: 4),

            Text(
              data.label,

              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 24. SECONDARY NAVIGATION SCREENS
// ============================================================

class _SecondaryTabScreen extends StatelessWidget {
  const _SecondaryTabScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Logo(compact: true),

          const SizedBox(height: 50),

          Icon(icon, size: 65, color: BayColors.neon),

          const SizedBox(height: 22),

          Text(
            title,

            style: const TextStyle(
              color: BayColors.text,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,

            style: const TextStyle(
              color: BayColors.neon,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 25),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(19),

            decoration: BoxDecoration(
              color: BayColors.card,

              borderRadius: BorderRadius.circular(20),

              border: Border.all(color: BayColors.border),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMING SOON',

                  style: TextStyle(
                    color: BayColors.lime,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 13),

                Text(
                  description,

                  style: const TextStyle(color: BayColors.muted, height: 1.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 25. SHOP / WALLET / PUNDIT / PASSPORT PREVIEW
// ============================================================

class FeaturePreviewScreen extends StatelessWidget {
  const FeaturePreviewScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BayColors.bg,

      body: _BayBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),

                  icon: const Icon(Icons.arrow_back, color: BayColors.text),
                ),

                const SizedBox(height: 30),

                const _Logo(compact: true),

                const SizedBox(height: 50),

                Icon(icon, size: 65, color: BayColors.neon),

                const SizedBox(height: 20),

                Text(
                  title.toUpperCase(),

                  style: const TextStyle(
                    color: BayColors.text,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  description,

                  style: const TextStyle(
                    color: BayColors.muted,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: BayColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: BayColors.border),
                  ),

                  child: const Text(
                    'This section is ready for its next development stage.',

                    style: TextStyle(
                      color: BayColors.neon,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 26. PROFILE ERROR SCREEN
// ============================================================

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.error, required this.onRetry});

  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: BayColors.orange,
              size: 50,
            ),

            const SizedBox(height: 17),

            const Text(
              'PROFILE COULD NOT LOAD',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: BayColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              error,

              textAlign: TextAlign.center,

              style: const TextStyle(color: BayColors.muted, fontSize: 12),
            ),

            const SizedBox(height: 20),

            _GradientButton(label: 'TRY AGAIN', onTap: onRetry, height: 48),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 27. LOGO
// ============================================================

class _Logo extends StatelessWidget {
  const _Logo({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 34.0 : 42.0;

    return Row(
      children: [
        SizedBox(
          width: logoSize,
          height: logoSize,

          child: Stack(
            alignment: Alignment.center,

            children: [
              CustomPaint(
                size: Size(logoSize, logoSize),
                painter: _HexPainter(),
              ),

              Text(
                'B',

                style: TextStyle(
                  color: BayColors.neon,
                  fontSize: compact ? 17 : 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: compact ? 8 : 12),

        Text(
          'BAYVER',

          style: TextStyle(
            color: BayColors.neon,
            fontSize: compact ? 20 : 26,
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? 4 : 7,

            shadows: const [
              Shadow(color: Color.fromRGBO(61, 255, 122, .6), blurRadius: 18),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 28. WELCOME HEADLINE
// ============================================================

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'YOUR SKILL\nFINALLY ',

        children: [
          TextSpan(
            text: 'COUNTS.',

            style: TextStyle(
              color: BayColors.neon,

              shadows: [
                Shadow(color: Color.fromRGBO(61, 255, 122, .6), blurRadius: 20),
              ],
            ),
          ),
        ],
      ),

      textAlign: TextAlign.center,

      style: TextStyle(
        color: BayColors.text,
        fontSize: 35,
        height: 1.08,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }
}

// ============================================================
// 29. GRADIENT BUTTON
// ============================================================

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    this.loading = false,
    this.height = 54,
    this.fontSize = 17,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;

  final bool loading;

  final double height;
  final double fontSize;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      height: height,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        gradient: const LinearGradient(
          colors: [BayColors.neon, BayColors.lime],
        ),

        boxShadow: [
          BoxShadow(
            color: BayColors.neon.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(14),

          onTap: loading ? null : onTap,

          child: Center(
            child: loading
                ? const SizedBox(
                    width: 23,
                    height: 23,

                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: BayColors.ink,
                    ),
                  )
                : Text(
                    label,

                    style: TextStyle(
                      color: BayColors.ink,
                      fontSize: fontSize,

                      fontWeight: FontWeight.w900,
                      letterSpacing: compact ? 1 : 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 30. HEXAGON LOGO PAINTER
// ============================================================

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// 31. WELCOME HERO PAINTER
// ============================================================
//
// This paints the glowing controller, crown, rings and chips.
// No image assets are required.
//

class _HeroPainter extends CustomPainter {
  const _HeroPainter();

  static const double _w = 342;
  static const double _h = 250;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / _w, size.height / _h);

    canvas.save();

    canvas.translate((size.width - _w * s) / 2, (size.height - _h * s) / 2);

    canvas.scale(s);

    // BACKGROUND GLOW

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
            Color.fromRGBO(61, 255, 122, .45),
            Color.fromRGBO(61, 255, 122, 0),
          ],
        ).createShader(glowRect),
    );

    // OUTER CIRCLE

    canvas.drawCircle(
      const Offset(171, 145),
      96,

      Paint()
        ..color = const Color(0xFF1E4D33)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // DASHED CIRCLE

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

    // CONTROLLER BODY

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

    // CONTROLLER GLOW

    canvas.drawPath(
      body,

      Paint()
        ..color = BayColors.neon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // CONTROLLER BODY

    canvas.drawPath(body, Paint()..color = BayColors.card);

    canvas.drawPath(
      body,

      Paint()
        ..color = BayColors.neon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    // D-PAD

    final dpad = Paint()
      ..color = BayColors.neon
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(122, 130), const Offset(142, 130), dpad);

    canvas.drawLine(const Offset(132, 120), const Offset(132, 140), dpad);

    // GAME BUTTONS

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

    // CROWN

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

    // FLOATING CHIPS

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

  // ----------------------------------------------------------
  // DASHED CIRCLE
  // ----------------------------------------------------------

  void _dashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    double dash,
    double gap,
  ) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dash, metric.length),
          ),
          paint,
        );

        distance += dash + gap;
      }
    }
  }

  // ----------------------------------------------------------
  // FLOATING CHIP
  // ----------------------------------------------------------

  void _chip(Canvas canvas, Rect rect, String label, Color color) {
    final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(15));

    canvas.drawRRect(rounded, Paint()..color = BayColors.card);

    canvas.drawRRect(
      rounded,

      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,

        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),

      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,

      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
