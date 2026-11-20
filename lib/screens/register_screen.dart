import 'package:flutter/material.dart';
import '../services/catering_service.dart';
import '../theme/app_colors.dart';
import '../widgets/liquid_glass_app_bar_components.dart';
import '../widgets/pill_text_field.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final CateringService _cateringService = CateringService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _showFieldErrors = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _showFieldErrors = true);
      return;
    }

    if (!_isPasswordStrong(password)) {
      setState(() => _showFieldErrors = true);
      return;
    }

    final ok = _cateringService.register(
      email: email,
      username: username,
      phone: phone,
      password: password,
    );

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau Email sudah terdaftar. Silakan masuk.'),
          backgroundColor: AppColors.tomatoBurst,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akun berhasil didaftarkan! Selamat datang di BEKALIMA.'),
        backgroundColor: Color(0xFF19532B),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  void _handleGoogleRegister() {
    _cateringService.register(
      email: 'user.google@gmail.com',
      username: 'User Google',
      phone: '081234567890',
      password: 'GoogleUser123!',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil mendaftar menggunakan Google'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFFA5805);

    return Scaffold(
      backgroundColor: brandOrange,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LiquidGlassCircle(
                        size: 40,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          tooltip: 'Kembali',
                        ),
                      ),
                      Semantics(
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const LoginScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                          child: LiquidGlassCapsule(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: AppColors.crispCarrot,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),


                  const Text(
                    'Daftar',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Silahkan membuat akun terlebih dahulu',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PillTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => _refreshErrors(),
                      errorText: _fieldError(
                        _emailController.text.trim().isEmpty,
                      ),
                    ),
                    const SizedBox(height: 14),
                    PillTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      onChanged: (_) => _refreshErrors(),
                      errorText: _fieldError(
                        _usernameController.text.trim().isEmpty,
                      ),
                    ),
                    const SizedBox(height: 14),
                    PillTextField(
                      controller: _phoneController,
                      hintText: 'No Telepon',
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => _refreshErrors(),
                      errorText: _fieldError(
                        _phoneController.text.trim().isEmpty,
                      ),
                    ),
                    const SizedBox(height: 14),
                    PillTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: !_isPasswordVisible,
                      onChanged: (_) => _refreshErrors(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF666666),
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      errorText: _passwordError,
                      helperText:
                          'Harus ada huruf besar, angka, simbol, dan minimal 8 karakter.',
                    ),
                    const SizedBox(height: 14),
                    PillTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Ulangi Password',
                      obscureText: !_isConfirmPasswordVisible,
                      onChanged: (_) => _refreshErrors(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF666666),
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      errorText: _fieldError(
                        _confirmPasswordController.text.trim().isEmpty,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const ValueKey('submit_register_button'),
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB100),
                          foregroundColor: Colors.black,
                          elevation: 3,
                          shadowColor: const Color(
                            0xFFFFB100,
                          ).withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFCCCCCC),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Atau',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color(0xFF888888),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleGoogleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/google_logo.png',
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Continue With Google',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _fieldError(bool isEmpty) {
    if (!_showFieldErrors || !isEmpty) return null;
    return 'Harap di isi terlebih dahulu.';
  }

  String? get _passwordError {
    if (!_showFieldErrors) return null;
    final password = _passwordController.text.trim();
    if (password.isEmpty) return 'Harap di isi terlebih dahulu.';
    if (!_isPasswordStrong(password)) {
      return 'Password minimal 8 karakter, harus ada huruf besar, angka, dan simbol.';
    }
    return null;
  }

  bool _isPasswordStrong(String value) {
    if (value.length < 8) return false;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(value);
    return hasUppercase && hasDigit && hasSymbol;
  }

  void _refreshErrors() {
    if (_showFieldErrors) setState(() {});
  }
}