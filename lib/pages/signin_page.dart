import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../services/firebase/auth.dart';
import 'main_navigation_screen.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;
  bool _forLogin = true;

  void _handleAuth(Function authAction) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await authAction();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Text(e.message ?? "An error occurred"),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// --- REFINED LOGO ---
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      "assets/images/W_logo.png",
                      width: 100, // Reduced from 150
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Walky",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// --- AUTH CARD ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _forLogin ? "Welcome Back" : "Join the Journey",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _forLogin
                              ? "Sign in to continue walking"
                              : "Create an account to start earning",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                        const SizedBox(height: 25),

                        /// EMAIL
                        _roundedField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value!.isEmpty) return "Enter your email";
                            if (!value.contains("@")) return "Invalid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// PASSWORD
                        _roundedField(
                          controller: _passwordController,
                          label: "Password",
                          icon: Icons.lock_outline_rounded,
                          obscure: _isObscure,
                          toggle: () => setState(() => _isObscure = !_isObscure),
                          validator: (value) {
                            if (value!.length < 6) return "Min 6 characters";
                            return null;
                          },
                        ),

                        if (!_forLogin) ...[
                          const SizedBox(height: 16),
                          _roundedField(
                            controller: _passwordConfirmController,
                            label: "Confirm Password",
                            icon: Icons.lock_reset_rounded,
                            obscure: _isObscure,
                            validator: (value) {
                              if (value != _passwordController.text) return "Passwords mismatch";
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 24),

                        /// PRIMARY BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.PrimApp,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                              _handleAuth(() async {
                                if (_forLogin) {
                                  await AuthService().loginWithEmailAndPassword(
                                      _emailController.text, _passwordController.text);
                                } else {
                                  await AuthService().createUserWithEmailAndPassword(
                                      _emailController.text, _passwordController.text);
                                }
                              });
                            },
                            child: _isLoading
                                ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                                : Text(
                              _forLogin ? "Log In" : "Sign Up",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// TOGGLE BUTTON
                        GestureDetector(
                          onTap: () {
                            _formKey.currentState!.reset();
                            setState(() => _forLogin = !_forLogin);
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black54, fontSize: 14),
                              children: [
                                TextSpan(text: _forLogin ? "New to Walky? " : "Already a member? "),
                                TextSpan(
                                  text: _forLogin ? "Create Account" : "Sign In",
                                  style: const TextStyle(
                                      color: AppColors.PrimApp,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),

                        /// GOOGLE LOGIN
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            icon: Image.asset("assets/images/google_logo.png", width: 22),
                            label: const Text(
                              "Continue with Google",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                            ),
                            onPressed: _isLoading ? null : () async {
                              setState(() => _isLoading = true);
                              await AuthService().signInWithGoogle();
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                              );
                            },
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
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.PrimApp, size: 20),
        suffixIcon: toggle != null
            ? IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey, size: 20),
          onPressed: toggle,
        )
            : null,
        filled: true,
        fillColor: const Color(0xfff8f9fa),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.PrimApp, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}