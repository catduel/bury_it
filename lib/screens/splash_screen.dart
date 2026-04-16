import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    final hasSession = await SupabaseService.checkExistingSession();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              hasSession ? const HomeScreen() : const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - Broken Heart
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFa78bfa), Color(0xFF8b5cf6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFa78bfa).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(70, 65),
                    painter: BrokenHeartPainter(),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 800.ms),

              const SizedBox(height: 30),

              // App Name
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFa78bfa), Color(0xFFf472b6)],
                ).createShader(bounds),
                child: const Text(
                  'BURY IT',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              const SizedBox(height: 12),

              // Tagline
              Text(
                'Let go of the past',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

              const SizedBox(height: 50),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFa78bfa).withOpacity(0.7),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for broken heart
class BrokenHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Left half of heart
    path.moveTo(size.width * 0.5, size.height * 0.25);
    path.cubicTo(
      size.width * 0.35, size.height * 0.0,
      size.width * 0.0, size.height * 0.1,
      size.width * 0.0, size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.0, size.height * 0.65,
      size.width * 0.45, size.height * 0.9,
      size.width * 0.45, size.height * 0.9,
    );

    // Right half of heart
    final path2 = Path();
    path2.moveTo(size.width * 0.5, size.height * 0.25);
    path2.cubicTo(
      size.width * 0.65, size.height * 0.0,
      size.width * 1.0, size.height * 0.1,
      size.width * 1.0, size.height * 0.4,
    );
    path2.cubicTo(
      size.width * 1.0, size.height * 0.65,
      size.width * 0.55, size.height * 0.9,
      size.width * 0.55, size.height * 0.9,
    );

    // Draw fill
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path2, fillPaint);
    
    // Draw strokes
    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);

    // Draw crack/break line in middle
    final crackPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final crackPath = Path();
    crackPath.moveTo(size.width * 0.42, size.height * 0.3);
    crackPath.lineTo(size.width * 0.55, size.height * 0.55);
    canvas.drawPath(crackPath, crackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
