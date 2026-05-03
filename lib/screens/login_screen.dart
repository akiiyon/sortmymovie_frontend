// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _bg = Color(0xFF0C0C12);
  static const _gold = Color(0xFFE8C547);
  static const _surface = Color(0xFF1A1A24);
  static const _border = Color(0xFF2A2A38);

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(_emailController.text, _passwordController.text);
      // main.dart Consumer detects isAuthenticated = true and swaps to HomeScreen
    } catch (e) {
      print(e); // keep this simple — don't add mounted checks or SnackBars here
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Hero banner ──────────────────────────────────────
              Container(
                height: 200,
                width: double.infinity,
                color: _bg,
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SORT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 3,
                              color: Color(0xB3E8C547),
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'My',
                                  style: TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                    letterSpacing: 2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Movie',
                                  style: TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w900,
                                    color: _gold,
                                    height: 1,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome back, cinephile.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // ── Form ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      // // ── Forgot password ───────────────────────────
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: () {},
                      //     style: TextButton.styleFrom(
                      //       padding: const EdgeInsets.symmetric(vertical: 8),
                      //     ),
                      //     child: const Text(
                      //       'Forgot password?',
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         color: Color(0x99E8C547),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 42),

                      // ── Login button ──────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: _bg,
                            disabledBackgroundColor: _gold.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _bg,
                                  ),
                                )
                              : const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Don't have an account ─────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white38,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Create one',
                              style: TextStyle(
                                fontSize: 13,
                                color: _gold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    const gold = Color(0xFFE8C547);
    const surface = Color(0xFF1A1A24);
    const border = Color(0xFF2A2A38);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.9,
            color: Colors.white38,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, size: 18, color: Colors.white38),
            filled: true,
            fillColor: surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: gold, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE24B4A)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE24B4A)),
            ),
          ),
        ),
      ],
    );
  }
}
