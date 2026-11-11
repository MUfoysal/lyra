import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String _heroAsset = 'assets/images/splash.png';
  static const Alignment _heroAlignment = Alignment.topCenter;
  static const double _heroFraction = 0.58;
  static const double _heroShift = 0.07;
  static const double _thumb = 56;
  static const double _trackHeight = 66;
  static const double _trackPad = 5;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  late final AnimationController _eq = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  late final AnimationController _slide = AnimationController(vsync: this);

  bool _launched = false;

  @override
  void dispose() {
    _intro.dispose();
    _zoom.dispose();
    _eq.dispose();
    _slide.dispose();
    super.dispose();
  }

  void _go() {
    if (_launched || !mounted) return;
    _launched = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  Widget _reveal({
    required double begin,
    required double end,
    required Widget child,
  }) {
    final interval = Interval(begin, end, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: _intro,
      child: child,
      builder: (context, child) {
        final t = interval.transform(_intro.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 680;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -size.height * _heroShift,
            left: 0,
            right: 0,
            height: size.height * (_heroFraction + _heroShift),
            child: _buildHero(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                children: [
                  _reveal(begin: 0, end: 0.4, child: _buildHeader()),
                  const Spacer(),
                  _reveal(begin: 0.1, end: 0.5, child: _buildStatusChip()),
                  const SizedBox(height: 14),
                  _reveal(
                    begin: 0.15,
                    end: 0.6,
                    child: _buildPanel(compact),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _zoom,
            builder: (context, child) {
              final scale =
                  1.0 + 0.07 * Curves.easeInOut.transform(_zoom.value);
              return Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: child,
              );
            },
            child: Image.asset(
              _heroAsset,
              fit: BoxFit.cover,
              alignment: _heroAlignment,
              frameBuilder: (context, child, frame, wasSyncLoaded) {
                if (wasSyncLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.headphones_rounded,
                    size: 110,
                    color: AppColors.primaryRed,
                  ),
                );
              },
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.18, 0.62, 1],
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glass({
    required Widget child,
    required EdgeInsets padding,
    double radius = 10,
    double blur = 14,
    double alpha = 0.45,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'L Y R A',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'BlackOpsOne',
              fontSize: 28,
              letterSpacing: 2,
              color: Color.fromARGB(255, 245, 6, 6),
              shadows: [
                Shadow(color: Color(0x99000000), blurRadius: 14),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _glass(
              radius: 8,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'OFFLINE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return _glass(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      radius: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEqualizer(maxHeight: 14, bars: 4),
          const SizedBox(width: 10),
          const Text(
            'YOUR LOCAL LIBRARY',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(bool compact) {
    final titleSize = compact ? 26.0 : 32.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.14),
            blurRadius: 40,
            spreadRadius: 1,
          ),
        ],
      ),
      child: _glass(
        radius: 28,
        blur: 22,
        alpha: 0.55,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _reveal(
              begin: 0.25,
              end: 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR MUSIC.',
                    style: TextStyle(
                      fontFamily: 'BlackOpsOne',
                      fontSize: titleSize,
                      height: 1.15,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [AppColors.primaryRed, Color(0xFFFF5A64)],
                    ).createShader(rect),
                    child: Text(
                      'YOUR WORLD.',
                      style: TextStyle(
                        fontFamily: 'BlackOpsOne',
                        fontSize: titleSize,
                        height: 1.15,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _reveal(
              begin: 0.4,
              end: 0.8,
              child: const Text(
                'A personal space for your favorite sounds. '
                'Discover your collection and enjoy every moment with music.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.65,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: compact ? 16 : 22),
            _reveal(begin: 0.55, end: 0.95, child: _buildSlideToStart()),
            const SizedBox(height: 14),
            _reveal(begin: 0.65, end: 1, child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideToStart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - _thumb - _trackPad * 2;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            if (_launched) return;
            await _slide.animateTo(
              1,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
            );
            _go();
          },
          onHorizontalDragUpdate: (details) {
            if (_launched) return;
            _slide.value = (_slide.value + details.delta.dx / maxDrag)
                .clamp(0.0, 1.0)
                .toDouble();
          },
          onHorizontalDragEnd: (_) async {
            if (_launched) return;
            if (_slide.value > 0.8) {
              await _slide.animateTo(
                1,
                duration: const Duration(milliseconds: 150),
              );
              _go();
            } else {
              _slide.animateTo(
                0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
              );
            }
          },
          child: AnimatedBuilder(
            animation: _slide,
            builder: (context, _) {
              final p = _slide.value;
              return Container(
                height: _trackHeight,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(_trackHeight),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: _trackPad,
                      top: _trackPad,
                      child: Container(
                        width: _thumb + p * maxDrag,
                        height: _thumb,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_thumb),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9E1422), Color(0xFFE32636)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: _thumb),
                        child: Opacity(
                          opacity: (1 - p * 1.8).clamp(0.0, 1.0).toDouble(),
                          child: const Text(
                            'SLIDE TO START',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _trackPad + p * maxDrag,
                      top: _trackPad,
                      child: Container(
                        width: _thumb,
                        height: _thumb,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 24,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.headphones_rounded,
          size: 13,
          color: AppColors.primaryRed,
        ),
        SizedBox(width: 7),
        Text(
          'NO INTERNET REQUIRED',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEqualizer({double maxHeight = 16, int bars = 5}) {
    return SizedBox(
      height: maxHeight,
      child: AnimatedBuilder(
        animation: _eq,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bars, (i) {
              final wave =
                  0.5 + 0.5 * math.sin(2 * math.pi * (_eq.value + i * 0.19));
              return Container(
                width: 3,
                height: 4 + (maxHeight - 4) * wave,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}