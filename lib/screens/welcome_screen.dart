import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
 
  late final AnimationController _arrowBounceController;
  late final Animation<double> _arrowBounceAnimation;
  late final Animation<double> _pulseRingAnimation;

  
  late final AnimationController _logoFloatController;
  late final Animation<double> _logoFloatAnimation;
  late final Animation<double> _logoScaleAnimation;

 
  bool _isSheetOpen = false;

  @override
  void initState() {
    super.initState();

    _arrowBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _arrowBounceAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _arrowBounceController,
        curve: Curves.easeInOutSine,
      ),
    );

    _pulseRingAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(
        parent: _arrowBounceController,
        curve: Curves.easeOutQuad,
      ),
    );

  
    _logoFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _logoFloatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _logoFloatController,
        curve: Curves.easeInOutSine,
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _logoFloatController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _arrowBounceController.dispose();
    _logoFloatController.dispose();
    super.dispose();
  }

  void _openWelcomeSheet() {
    setState(() {
      _isSheetOpen = true;
    });
  }

  void _closeWelcomeSheet() {
    setState(() {
      _isSheetOpen = false;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFFA5805); // Warna oranye cerah khas BEKALIMA
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: brandOrange,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Swipe ke atas untuk membuka sheet
          if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
            _openWelcomeSheet();
          } else if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
            _closeWelcomeSheet();
          }
        },
        child: Stack(
          children: [
            // Konten Utama: Logo Bento & Teks BEKALIMA
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    // Memberikan proporsi posisi logo yang pas di tengah atas
                    SizedBox(height: _isSheetOpen ? screenHeight * 0.04 : screenHeight * 0.12),

                    // Logo Bento dengan animasi floating & breathing halus
                    AnimatedBuilder(
                      animation: _logoFloatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _logoFloatAnimation.value),
                          child: Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 195,
                        height: 195,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9EED9), // Warna cream beige lingkaran
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text('🍱', style: TextStyle(fontSize: 84)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Judul BEKALIMA
                    const Text(
                      'BEKALIMA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle Healty Food Catering
                    Text(
                      'Healty Food Catering',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.92),
                        letterSpacing: 0.3,
                      ),
                    ),

                    const Spacer(),

                    
                    AnimatedOpacity(
                      opacity: _isSheetOpen ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: IgnorePointer(
                        ignoring: _isSheetOpen,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 44.0),
                          child: _buildAnimatedArrowButton(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isSheetOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeWelcomeSheet,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.01),
                  ),
                ),
              ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              bottom: _isSheetOpen ? 0 : -340,
              child: _buildWelcomeCard(screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedArrowButton() {
    return AnimatedBuilder(
      animation: _arrowBounceController,
      builder: (context, child) {
        final ringOpacity = (1.0 - (_pulseRingAnimation.value - 1.0) / 0.35).clamp(0.0, 0.45);
        return Transform.translate(
          offset: Offset(0, _arrowBounceAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Efek lingkaran pulsing ring di sekeliling tombol
              IgnorePointer(
                child: Transform.scale(
                  scale: _pulseRingAnimation.value,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFB100).withValues(alpha: ringOpacity),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openWelcomeSheet,
                child: Material(
                  color: const Color(0xFFFFB100), // Warna kuning emas terang sesuai gambar
                  shape: const CircleBorder(),
                  elevation: 4,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  child: Container(
                    key: const ValueKey('welcome_arrow_button'),
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFF141414),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildWelcomeCard(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x2B000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Judul Selamat Datang
          const Text(
            'Selamat Datang',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            'Selamat datang di BEKALIMA, tempat kamu menemukan berbagai hidangan lezat dan bergizi yang disiapkan dengan sepenuh hati untuk menemani setiap momen spesialmu.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              // Tombol Masuk (Kuning/Oranye terang)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    key: const ValueKey('welcome_masuk_button'),
                    onPressed: _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAC00),
                      foregroundColor: const Color(0xFF111111),
                      elevation: 3,
                      shadowColor: const Color(0xFFFFAC00).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    // Tombol Masuk
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Tombol Daftar (Hitam)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    key: const ValueKey('welcome_daftar_button'),
                    onPressed: _navigateToRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    // Tombol Daftar
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}