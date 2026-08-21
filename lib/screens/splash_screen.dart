import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Custom Stylized Logo
              CustomPaint(
                size: const Size(80, 80),
                painter: LogoPainter(),
              ),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'Nourish',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Understand your nutrition. Build healthier habits.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Minimal Loading Indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Draw leaf shape
    path.moveTo(size.width * 0.5, size.height * 0.1);
    
    // Right curve
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.7,
    );
    
    // Bottom curve
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.95,
      size.width * 0.2,
      size.height * 0.7,
    );
    
    // Left curve
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.1,
    );

    canvas.drawPath(path, paint);

    // Draw white leaf vein
    final veinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final veinPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.85)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..moveTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.65, size.height * 0.55)
      ..moveTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.45);

    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
