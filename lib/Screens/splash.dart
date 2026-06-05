import 'package:ed_app/Screens/login.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ED Ventilator Maintenance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _bounceController;

  final Color primaryBlue = const Color(0xFF0E4F87);
  final Color babyBlue = const Color(0xFFD7F1FF);
  final Color softNavy = const Color(0xFF1A2B3C);
  final Color mediumGray = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    // ⬅️ هنا نحط الانتقال للّوجين
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    });

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFFFF),
              babyBlue,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, babyBlue],
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _fadeController,
                  curve: Curves.easeOut,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale = 1.0 +
                                  (math.sin(
                                        _pulseController.value * 2 * math.pi,
                                      ) *
                                      0.05);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: babyBlue.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),

                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0E4F87).withOpacity(0.3),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '⚕️',
                                style: TextStyle(
                                  fontSize: 64,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'ED Ventilator Maintenance System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: softNavy,
                          fontFamily: 'Roboto Mono',
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Emergency Department Medical Equipment Management',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: mediumGray,
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(0.0),
                        const SizedBox(width: 12),
                        _buildDot(0.2),
                        const SizedBox(width: 12),
                        _buildDot(0.4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(double delaySeconds) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final delayNormalized = delaySeconds / 1.4;
        double t = _bounceController.value - delayNormalized;
        if (t < 0) t += 1.0;

        double translateY = 0;
        double opacity = 0.5;

        if (t <= 0.4) {
          final progress = Curves.easeInOut.transform(t / 0.4);
          translateY = -20 * progress;
          opacity = 0.5 + (0.5 * progress);
        } else if (t <= 0.8) {
          final progress = Curves.easeInOut.transform((t - 0.4) / 0.4);
          translateY = -20 * (1 - progress);
          opacity = 1.0 - (0.5 * progress);
        } else {
          translateY = 0;
          opacity = 0.5;
        }

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
