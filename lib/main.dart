import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'screens/welcome_screen.dart';
import 'services/theme_controller.dart';
import 'theme/theme.dart';

void main() {
  runApp(const BekalimaApp());
}

class BekalimaApp extends StatefulWidget {
  const BekalimaApp({super.key});

  @override
  State<BekalimaApp> createState() => _BekalimaAppState();
}

class _BekalimaAppState extends State<BekalimaApp>
    with SingleTickerProviderStateMixin {
  final GlobalKey _rootKey = GlobalKey();

  late final AnimationController _revealController;
  ui.Image? _oldFrame;
  Offset _origin = Offset.zero;
  double _maxRadius = 0;
  double _pixelRatio = 1;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addStatusListener(_handleRevealStatus);
    ThemeController.instance.addListener(_handleThemeChange);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_handleThemeChange);
    _revealController.dispose();
    _oldFrame?.dispose();
    super.dispose();
  }

  void _handleRevealStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _oldFrame == null) return;

    final frame = _oldFrame;
    setState(() => _oldFrame = null);
    WidgetsBinding.instance.addPostFrameCallback((_) => frame?.dispose());
  }

  /// Mengambil potret layar lama, lalu tema baru muncul lewat lingkaran yang
  /// melebar dari tombol. Potret dipakai supaya isi tema lama tidak ikut
  /// berubah warna sebelum lingkaran menutupinya.
  Future<void> _handleThemeChange() async {
    if (!mounted) return;

    if (_revealController.isAnimating) {
      _revealController
        ..stop()
        ..value = 1;
      return;
    }

    final controller = ThemeController.instance;
    final view = View.of(context);
    final pixelRatio = view.devicePixelRatio;
    final size = view.physicalSize / pixelRatio;
    final origin = controller.toggleOrigin ?? Offset(size.width - 24, 24);
    final boundary =
        _rootKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      setState(() {});
      return;
    }

    // Pastikan frame terakhir sudah selesai dilukis sebelum dipotret.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    ui.Image? frame;
    try {
      frame = await boundary.toImage(pixelRatio: pixelRatio);
    } on Object {
      frame = null;
    }
    if (!mounted) {
      frame?.dispose();
      return;
    }

    setState(() {
      _oldFrame?.dispose();
      _oldFrame = frame;
      _origin = origin;
      _pixelRatio = pixelRatio;
      _maxRadius = _farthestCornerDistance(origin, size);
    });

    if (frame != null) {
      _revealController.forward(from: 0);
    }
  }

  double _farthestCornerDistance(Offset center, Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    var max = 0.0;
    for (final corner in corners) {
      final distance = (corner - center).distance;
      if (distance > max) max = distance;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _rootKey,
      child: MaterialApp(
        title: 'BEKALIMA - Katering Online',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeController.instance.themeMode,
        themeAnimationStyle: AnimationStyle.noAnimation,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ?child,
              if (_oldFrame != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _revealController,
                      builder: (context, _) {
                        final progress = Curves.easeInOutCubic.transform(
                          _revealController.value,
                        );
                        return ClipPath(
                          clipper: _RevealHoleClipper(
                            center: _origin,
                            radius: _maxRadius * progress,
                          ),
                          child: RawImage(
                            image: _oldFrame,
                            scale: _pixelRatio,
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
        home: const WelcomeScreen(),
      ),
    );
  }
}

/// Memotong potret tema lama dengan lubang lingkaran yang terus membesar,
/// sehingga tema baru di bawahnya terlihat "melebar" dari titik tombol.
class _RevealHoleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  const _RevealHoleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path()..fillType = PathFillType.evenOdd;
    path.addRect(Offset.zero & size);
    if (radius > 0) {
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    }
    return path;
  }

  @override
  bool shouldReclip(_RevealHoleClipper oldClipper) =>
      oldClipper.center != center || oldClipper.radius != radius;
}