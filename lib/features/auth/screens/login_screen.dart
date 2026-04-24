import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_screen.dart';
import '../../../home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  const LoginScreen({super.key, required this.onLogin, required this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _getCode() async {
    if (_phoneCtrl.text.length < 10) return;
    _focusNode.unfocus();
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: _phoneCtrl.text.trim(),
          onVerified: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Blue header ──
            _BlueHeader(height: size.height * 0.30),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone Number label
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Phone input field
                  GestureDetector(
                    onTap: () => _focusNode.requestFocus(),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? const Color(0xFF2B3EE6)
                              : const Color(0xFFDDDDDD),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Text('🇧🇩', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          const Text(
                            '+880',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 22, color: const Color(0xFFDDDDDD)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _phoneCtrl,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: '017XXXXXXXX',
                                hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF222222),
                                letterSpacing: 1,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Get Code button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _getCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B3EE6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Terms
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF888888)),
                        children: [
                          TextSpan(text: 'You '),
                          TextSpan(text: 'Agree', style: TextStyle(color: Color(0xFF2B3EE6))),
                          TextSpan(text: ' to our '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(color: Color(0xFF2B3EE6), fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' and\n'),
                          TextSpan(
                            text: 'privacy Policy',
                            style: TextStyle(color: Color(0xFF2B3EE6), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Blue header with wave ──
class _BlueHeader extends StatelessWidget {
  final double height;
  const _BlueHeader({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D52F5), Color(0xFF2B3EE6)],
              ),
            ),
          ),
          CustomPaint(
            size: Size(double.infinity, height),
            painter: _HeaderStripePainter(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 40),
              painter: _WavePainter(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B3EE6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: const _MiniAppIcon(),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Doctor List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
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

class _HeaderStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.55, 0)
        ..lineTo(size.width * 0.75, 0)
        ..lineTo(size.width * 0.45, size.height)
        ..lineTo(size.width * 0.25, size.height)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.72, 0)
        ..lineTo(size.width * 0.82, 0)
        ..lineTo(size.width * 0.62, size.height)
        ..lineTo(size.width * 0.52, size.height)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _MiniAppIcon extends StatelessWidget {
  const _MiniAppIcon();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _MiniIconPainter());
}

class _MiniIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final white = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.16, white);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.22, h * 0.85)
        ..quadraticBezierTo(w * 0.22, h * 0.58, w * 0.5, h * 0.54)
        ..quadraticBezierTo(w * 0.78, h * 0.58, w * 0.78, h * 0.85)
        ..close(),
      white,
    );
    canvas.drawCircle(Offset(w * 0.65, h * 0.65), w * 0.13, stroke);
    canvas.drawLine(Offset(w * 0.74, h * 0.74), Offset(w * 0.82, h * 0.82), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
