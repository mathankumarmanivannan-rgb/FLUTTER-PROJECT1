// =============================================================================
//  NOVA STUDENT PORTAL — main.dart
//  Three-page Flutter app: Login → Student Details Form → Details Display
//  Design: Aurora-dark theme · deep navy / teal / amber · Material 3
//  All code in one file for easy use in Android Studio.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ── Entry point ──────────────────────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait for a polished mobile feel
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Transparent status bar so gradient bleeds to the top edge
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const NovaApp());
}

// =============================================================================
//  DESIGN TOKENS — single source of truth for colours & gradients
// =============================================================================
class AppColors {
  // Dark navy background stops
  static const bg1 = Color(0xFF020818);
  static const bg2 = Color(0xFF051630);
  static const bg3 = Color(0xFF0A2A4A);

  // Cool accent palette
  static const a1 = Color(0xFF00C9B1); // teal
  static const a2 = Color(0xFF0EA5E9); // sky-blue
  static const a3 = Color(0xFF6366F1); // indigo

  // Warm accent palette
  static const warm1 = Color(0xFFF59E0B); // amber
  static const warm2 = Color(0xFFF97316); // orange

  // Text
  static const textPrimary = Color(0xFFE2F0FF);
  static const textSub     = Color(0xFF7BAFC8);

  // Gradients
  static const bgGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bg1, bg2, bg3],
    stops: [0.0, 0.5, 1.0],
  );
  static const accentGrad = LinearGradient(
    colors: [a1, a2, a3],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const warmGrad = LinearGradient(
    colors: [warm1, warm2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// =============================================================================
//  ROOT APP
// =============================================================================
class NovaApp extends StatelessWidget {
  const NovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova Student Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.a1,
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// =============================================================================
//  PAGE 1 — LOGIN PAGE
// =============================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _userCtrl  = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;

  // Entrance animation
  late final AnimationController _entranceAC;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  // Continuous slow ring rotation for illustration
  late final AnimationController _orbAC;

  @override
  void initState() {
    super.initState();

    _entranceAC = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnim = CurvedAnimation(
        parent: _entranceAC,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut));

    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _entranceAC,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic)));

    // Slow-spinning decorative ring
    _orbAC = AnimationController(
        vsync: this, duration: const Duration(seconds: 18))
      ..repeat();

    _entranceAC.forward();
  }

  @override
  void dispose() {
    _entranceAC.dispose();
    _orbAC.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Navigate to student details form ─────────────────────────────────────
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).push(
      _fadeScaleRoute(StudentDetailsPage(username: _userCtrl.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Background gradient
        Container(decoration: const BoxDecoration(gradient: AppColors.bgGrad)),
        // Decorative blurred orbs
        const _BackgroundOrbs(),
        // Scrollable content
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Column(children: [
              const SizedBox(height: 20),
              _buildIllustration(),
              const SizedBox(height: 24),
              _buildHeading(),
              const SizedBox(height: 32),
              // Fade + slide the login card in on load
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildCard(),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Login illustration (concentric rings + school icon) ─────────────────
  Widget _buildIllustration() {
    return SizedBox(
      height: 170,
      child: Stack(alignment: Alignment.center, children: [
        // Slowly rotating outer ring
        AnimatedBuilder(
          animation: _orbAC,
          builder: (_, __) => Transform.rotate(
            angle: _orbAC.value * 2 * math.pi,
            child: Container(
              width: 158,
              height: 158,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.a1.withOpacity(0.22), width: 1.2),
              ),
            ),
          ),
        ),
        // Glow halo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.a1.withOpacity(0.28),
              Colors.transparent,
            ]),
          ),
        ),
        // Icon circle
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.a1, AppColors.a3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: AppColors.a1.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 4),
            ],
          ),
          child:
          const Icon(Icons.school_rounded, color: Colors.white, size: 44),
        ),
        // Orbit dots
        ..._buildOrbitDots(78, 5,
            [AppColors.a1, AppColors.a2, AppColors.warm1, AppColors.a3, AppColors.warm2]),
      ]),
    );
  }

  /// Generate evenly-spaced dots around a circle of given [radius]
  List<Widget> _buildOrbitDots(
      double radius, double dotR, List<Color> colors) {
    return List.generate(colors.length, (i) {
      final angle = (i / colors.length) * 2 * math.pi - math.pi / 2;
      final cx = 85 + radius * math.cos(angle) - dotR;
      final cy = 85 + radius * math.sin(angle) - dotR;
      return Positioned(
        left: cx, top: cy,
        child: Container(
          width: dotR * 2, height: dotR * 2,
          decoration:
          BoxDecoration(shape: BoxShape.circle, color: colors[i]),
        ),
      );
    });
  }

  Widget _buildHeading() {
    return Column(children: [
      ShaderMask(
        shaderCallback: (r) => const LinearGradient(
            colors: [AppColors.a1, AppColors.a2])
            .createShader(r),
        child: const Text('NOVA PORTAL',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
                color: Colors.white)),
      ),
      const SizedBox(height: 6),
      const Text('Student Management System',
          style: TextStyle(
              fontSize: 13,
              color: AppColors.textSub,
              letterSpacing: 1.4)),
    ]);
  }

  Widget _buildCard() {
    return _GlassCard(
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionLabel('Sign In'),
          const SizedBox(height: 4),
          const Text('Access your student dashboard',
              style: TextStyle(color: AppColors.textSub, fontSize: 12.5)),
          const SizedBox(height: 28),
          // Username field
          _NovaField(
            controller: _userCtrl,
            label: 'Username',
            hint: 'Enter username',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Username is required' : null,
          ),
          const SizedBox(height: 16),
          // Password field
          _NovaField(
            controller: _passCtrl,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSub,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) =>
            (v == null || v.length < 4) ? 'Min. 4 characters' : null,
          ),
          const SizedBox(height: 28),
          // Login button
          _GradientButton(
            label: 'Login',
            icon: Icons.arrow_forward_rounded,
            gradient: AppColors.accentGrad,
            isLoading: _loading,
            onPressed: _handleLogin,
          ),
        ]),
      ),
    );
  }
}

// =============================================================================
//  DATA MODEL — carries all student info between pages
// =============================================================================
class StudentData {
  final String username;
  final String firstName;
  final String lastName;
  final String age;
  final String regNumber;
  final String gender;
  final String address;

  const StudentData({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.regNumber,
    required this.gender,
    required this.address,
  });
}

// =============================================================================
//  PAGE 2 — STUDENT DETAILS FORM
// =============================================================================
class StudentDetailsPage extends StatefulWidget {
  final String username;
  const StudentDetailsPage({super.key, required this.username});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage>
    with SingleTickerProviderStateMixin {
  final _formKey     = GlobalKey<FormState>();
  final _firstCtrl   = TextEditingController();
  final _lastCtrl    = TextEditingController();
  final _ageCtrl     = TextEditingController();
  final _regCtrl     = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _gender = 'Male';

  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _itemCount = 7; // number of staggered sections

  late final AnimationController _ac;
  late final List<Animation<double>>  _fadeList;
  late final List<Animation<Offset>>  _slideList;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    // Build staggered animations for each form section
    _fadeList = List.generate(_itemCount, (i) {
      final s = (i * 0.1).clamp(0.0, 0.6);
      return CurvedAnimation(
          parent: _ac,
          curve: Interval(s, (s + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOut));
    });

    _slideList = List.generate(_itemCount, (i) {
      final s = (i * 0.1).clamp(0.0, 0.6);
      return Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
          .animate(CurvedAnimation(
          parent: _ac,
          curve: Interval(s, (s + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic)));
    });

    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _ageCtrl.dispose();
    _regCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── Validate form and navigate to display page ───────────────────────────
  void _done() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final data = StudentData(
      username:  widget.username,
      firstName: _firstCtrl.text.trim(),
      lastName:  _lastCtrl.text.trim(),
      age:       _ageCtrl.text.trim(),
      regNumber: _regCtrl.text.trim(),
      gender:    _gender,
      address:   _addressCtrl.text.trim(),
    );
    Navigator.of(context)
        .push(_fadeScaleRoute(StudentDisplayPage(data: data)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: AppColors.bgGrad)),
        const _BackgroundOrbs(),
        SafeArea(
          child: Column(children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    _stagger(0, _GlassCard(child: _NovaField(
                      controller: _firstCtrl, label: 'First Name',
                      hint: 'e.g. Arjun', icon: Icons.badge_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required' : null,
                    ))),
                    const SizedBox(height: 14),
                    _stagger(1, _GlassCard(child: _NovaField(
                      controller: _lastCtrl, label: 'Last Name',
                      hint: 'e.g. Kumar', icon: Icons.badge_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required' : null,
                    ))),
                    const SizedBox(height: 14),
                    _stagger(2, _GlassCard(child: _NovaField(
                      controller: _ageCtrl, label: 'Age',
                      hint: 'e.g. 20', icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null || n < 5 || n > 100)
                          return 'Enter a valid age (5–100)';
                        return null;
                      },
                    ))),
                    const SizedBox(height: 14),
                    _stagger(3, _GlassCard(child: _NovaField(
                      controller: _regCtrl, label: 'Register Number',
                      hint: 'e.g. 2024CS042',
                      icon: Icons.confirmation_number_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required' : null,
                    ))),
                    const SizedBox(height: 14),
                    _stagger(4, _buildGenderCard()),
                    const SizedBox(height: 14),
                    _stagger(5, _GlassCard(child: _NovaField(
                      controller: _addressCtrl, label: 'Address',
                      hint: 'Enter full address…',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required' : null,
                    ))),
                    const SizedBox(height: 28),
                    _stagger(6, _GradientButton(
                      label: 'Done',
                      icon: Icons.check_circle_rounded,
                      gradient: AppColors.warmGrad,
                      onPressed: _done,
                    )),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _stagger(int i, Widget child) => FadeTransition(
    opacity: _fadeList[i],
    child: SlideTransition(position: _slideList[i], child: child),
  );

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          ShaderMask(
            shaderCallback: (r) => AppColors.accentGrad.createShader(r),
            child: const Text('Student Details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5)),
          ),
          const Text('Fill in your information',
              style: TextStyle(fontSize: 11, color: AppColors.textSub)),
        ]),
      ]),
    );
  }

  // Gender selector with animated pill chips
  Widget _buildGenderCard() {
    return _GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.wc_rounded, color: AppColors.a1, size: 18),
          const SizedBox(width: 8),
          _sectionLabel('Gender'),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: _genders.map((g) {
            final selected = _gender == g;
            return GestureDetector(
              onTap: () => setState(() => _gender = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: selected ? AppColors.accentGrad : null,
                  color: selected
                      ? null
                      : Colors.white.withOpacity(0.07),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.15),
                  ),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                        color: AppColors.a1.withOpacity(0.3),
                        blurRadius: 12)
                  ]
                      : null,
                ),
                child: Text(g,
                    style: TextStyle(
                        color:
                        selected ? Colors.white : AppColors.textSub,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// =============================================================================
//  PAGE 3 — STUDENT DETAILS DISPLAY
// =============================================================================
class StudentDisplayPage extends StatefulWidget {
  final StudentData data;
  const StudentDisplayPage({super.key, required this.data});

  @override
  State<StudentDisplayPage> createState() => _StudentDisplayPageState();
}

class _StudentDisplayPageState extends State<StudentDisplayPage>
    with SingleTickerProviderStateMixin {
  static const _cardCount = 7;

  late final AnimationController _ac;
  late final List<Animation<double>>  _fadeList;
  late final List<Animation<Offset>>  _slideList;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _fadeList = List.generate(_cardCount, (i) {
      final s = (i * 0.09).clamp(0.0, 0.65);
      return CurvedAnimation(
          parent: _ac,
          curve: Interval(s, (s + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOut));
    });

    _slideList = List.generate(_cardCount, (i) {
      final s = (i * 0.09).clamp(0.0, 0.65);
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(
          parent: _ac,
          curve: Interval(s, (s + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic)));
    });

    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Scaffold(
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: AppColors.bgGrad)),
        const _BackgroundOrbs(),
        SafeArea(
          child: Column(children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                ShaderMask(
                  shaderCallback: (r) => AppColors.warmGrad.createShader(r),
                  child: const Text('Student Profile',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
                child: Column(children: [
                  // Hero card with avatar + welcome
                  _anim(0, _buildHero(d)),
                  const SizedBox(height: 20),
                  // Individual detail rows (staggered)
                  _anim(1, _DetailRow(label: 'First Name',    value: d.firstName, icon: Icons.badge_outlined,                accentIndex: 0)),
                  const SizedBox(height: 12),
                  _anim(2, _DetailRow(label: 'Last Name',     value: d.lastName,  icon: Icons.badge_rounded,                 accentIndex: 1)),
                  const SizedBox(height: 12),
                  _anim(3, _DetailRow(label: 'Age',           value: '${d.age} years', icon: Icons.cake_outlined,            accentIndex: 2)),
                  const SizedBox(height: 12),
                  _anim(4, _DetailRow(label: 'Register No.',  value: d.regNumber, icon: Icons.confirmation_number_outlined,  accentIndex: 3)),
                  const SizedBox(height: 12),
                  _anim(5, _DetailRow(label: 'Gender',        value: d.gender,    icon: Icons.wc_rounded,                    accentIndex: 4)),
                  const SizedBox(height: 12),
                  _anim(6, _DetailRow(label: 'Address',       value: d.address,   icon: Icons.location_on_outlined,          accentIndex: 5)),
                  const SizedBox(height: 28),
                  // Return to login
                  _GradientButton(
                    label: 'Back to Login',
                    icon: Icons.home_rounded,
                    gradient: AppColors.accentGrad,
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _anim(int i, Widget child) => FadeTransition(
    opacity: _fadeList[i],
    child: SlideTransition(position: _slideList[i], child: child),
  );

  // ── Hero section — avatar + greeting + reg badge ─────────────────────────
  Widget _buildHero(StudentData d) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.a1.withOpacity(0.22),
            AppColors.a3.withOpacity(0.14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
            color: AppColors.a1.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: AppColors.a1.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: [
        // Avatar
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.warm1, AppColors.warm2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: AppColors.warm1.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 2),
            ],
          ),
          child: const Icon(Icons.person_rounded,
              color: Colors.white, size: 46),
        ),
        const SizedBox(height: 14),
        // Greeting
        const Text('Hello,',
            style: TextStyle(
                color: AppColors.textSub, fontSize: 15, letterSpacing: 1)),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (r) => AppColors.accentGrad.createShader(r),
          child: Text(
            d.username.isEmpty ? 'Student' : d.username,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text('${d.firstName} ${d.lastName}',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                letterSpacing: 0.5)),
        const SizedBox(height: 12),
        // Register number badge
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: AppColors.a1.withOpacity(0.14),
            border: Border.all(
                color: AppColors.a1.withOpacity(0.4), width: 1),
          ),
          child: Text('ID: ${d.regNumber}',
              style: const TextStyle(
                  color: AppColors.a1,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ),
      ]),
    );
  }
}

// =============================================================================
//  SHARED / REUSABLE WIDGETS
// =============================================================================

/// Semi-transparent frosted glass card
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.05),
        border:
        Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

/// Dark-themed text field with label + leading icon
class _NovaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _NovaField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: AppColors.a1, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      ]),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        cursorColor: AppColors.a1,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: AppColors.textSub.withOpacity(0.45), fontSize: 13),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          errorStyle:
          const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: AppColors.a1, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: Color(0xFFFCA5A5)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFFCA5A5), width: 1.6),
          ),
        ),
      ),
    ]);
  }
}

/// Press-scale animated gradient CTA button
class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.gradient,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pc;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pc = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _pc, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _pc.forward() : null,
      onTapUp: widget.onPressed != null
          ? (_) {
        _pc.reverse();
        widget.onPressed?.call();
      }
          : null,
      onTapCancel:
      widget.onPressed != null ? () => _pc.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                  AlwaysStoppedAnimation(Colors.white)))
              : Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.8)),
            const SizedBox(width: 10),
            Icon(widget.icon, color: Colors.white, size: 18),
          ]),
        ),
      ),
    );
  }
}

/// A single labelled row on the display page with accent-coloured icon
class _DetailRow extends StatelessWidget {
  final String  label;
  final String  value;
  final IconData icon;
  final int     accentIndex;

  static const _palette = [
    AppColors.a1, AppColors.a2, AppColors.a3,
    AppColors.warm1, AppColors.warm2, AppColors.a1,
  ];

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _palette[accentIndex % _palette.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: accent.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
              color: accent.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        // Accent icon tile
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: accent.withOpacity(0.15),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ]),
        ),
        Icon(Icons.chevron_right_rounded,
            color: accent.withOpacity(0.5), size: 18),
      ]),
    );
  }
}

/// Decorative radial-gradient orbs painted behind every page
class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(children: [
        // Top-right orb
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.a3.withOpacity(0.2),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Bottom-left orb
        Positioned(
          bottom: -80, left: -50,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.a1.withOpacity(0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Mid-right warm orb
        Positioned(
          top: 320, right: -30,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.warm1.withOpacity(0.14),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// =============================================================================
//  HELPER FUNCTIONS
// =============================================================================

/// Bold section label used inside cards
Widget _sectionLabel(String text) => Text(
  text,
  style: const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
  ),
);

/// Custom page route: simultaneous fade + gentle scale-up
PageRouteBuilder _fadeScaleRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, animation, __) => page,
  transitionDuration: const Duration(milliseconds: 480),
  transitionsBuilder: (_, animation, __, child) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);