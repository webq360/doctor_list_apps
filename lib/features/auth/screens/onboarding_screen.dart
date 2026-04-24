import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF2B3EE6),
      body: Stack(
        children: [
          // ── Background: Blue with diagonal stripes ──
          Positioned.fill(
            child: CustomPaint(painter: _StripePainter()),
          ),

          // ── Doctor image: positioned to extend behind the curve ──
          Positioned(
            top: size.height * 0.08,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/doctor.png',
              height: size.height * 0.58,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => SizedBox(
                height: size.height * 0.58,
                child: const Center(
                  child: Icon(Icons.person, size: 140, color: Colors.white38),
                ),
              ),
            ),
          ),

          // ── White card with concave curve on top (overlays doctor) ──
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _ConcaveClipper(),
              child: Container(
                width: double.infinity,
                height: size.height * 0.42,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(28, 50, 28, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    const Text(
                      'Doctor List',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B3EE6),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Subtitle
                    const Text(
                      'Now find contact numbers of all\ndoctors in your district',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      'Book appointments and see doctors\ndirectly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B3EE6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 15),
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
}

// Concave curve clipper
class _ConcaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 50);
    // Smooth concave curve at top
    path.quadraticBezierTo(
      size.width / 2, -35,  // control point above = inward dip
      size.width, 50,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.55, 0)
        ..lineTo(size.width * 0.78, 0)
        ..lineTo(size.width * 0.48, size.height * 0.65)
        ..lineTo(size.width * 0.25, size.height * 0.65)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.72, 0)
        ..lineTo(size.width * 0.88, 0)
        ..lineTo(size.width * 0.65, size.height * 0.65)
        ..lineTo(size.width * 0.49, size.height * 0.65)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
