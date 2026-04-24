import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final VoidCallback onVerified;
  const OtpScreen({super.key, required this.phone, required this.onVerified});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-fill OTP 5805 for testing
      _ctrls[0].text = '5';
      _ctrls[1].text = '8';
      _ctrls[2].text = '0';
      _ctrls[3].text = '5';
      setState(() {});
    });
    for (final n in _nodes) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _enteredOtp => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_enteredOtp.length < 4) return;

    final auth = context.read<AuthProvider>();
    final result = await auth.phoneLogin(widget.phone, _enteredOtp);

    if (!mounted) return;

    if (!result.success) {
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    widget.onVerified();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Verify Mobile Number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF888888), height: 1.5),
                    children: [
                      const TextSpan(text: 'Enter the 4-digit code sent to\n'),
                      TextSpan(
                        text: widget.phone,
                        style: const TextStyle(
                          color: Color(0xFF2B3EE6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final focused = _nodes[i].hasFocus;
                    final filled = _ctrls[i].text.isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: focused || filled
                              ? const Color(0xFF2B3EE6)
                              : const Color(0xFFCCCCCC),
                          width: focused ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                        onChanged: (val) {
                          setState(() {});
                          if (val.isNotEmpty && i < 3) {
                            _nodes[i + 1].requestFocus();
                          }
                          if (val.isEmpty && i > 0) {
                            _nodes[i - 1].requestFocus();
                          }
                          // Auto-verify when all 4 digits entered
                          if (_enteredOtp.length == 4) _verify();
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive code? ",
                      style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                    ),
                    GestureDetector(
                      onTap: () {
                        for (final c in _ctrls) c.clear();
                        _nodes[0].requestFocus();
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2B3EE6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B3EE6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    children: [
                      TextSpan(text: 'If you have any problems?\nplease '),
                      TextSpan(
                        text: 'contact us',
                        style: TextStyle(
                          color: Color(0xFF2B3EE6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
