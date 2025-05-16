// login_screen.dart
import 'dart:ui'; // Import for ImageFilter
import 'package:audiobook_e_library/auth/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../screens/bottom_nav_bar.dart';
import '../../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Login screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await ref
          .read(authProvider.notifier)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      setState(() => _isLoading = false);

      final state = ref.read(authProvider);
      if (state is AuthStateAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('showGetStarted', false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else if (state is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ), // Adjust blur intensity
              child: Container(
                color: Colors.black.withOpacity(
                  0.1,
                ), // Optional: Add a slight dark overlay for better readability
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const SizedBox(height: 20),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 48),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              filled: true,
                              fillColor: Color.fromRGBO(255, 255, 255, 0.3),
                              hintStyle: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.6),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(255, 255, 255, 0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(255, 255, 255, 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator:
                                (value) =>
                                    value != null && value.contains('@')
                                        ? null
                                        : 'Enter a valid email',
                          ),

                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: const Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.3,
                              ),
                              hintStyle: const TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.6),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color.fromRGBO(
                                    255,
                                    255,
                                    255,
                                    0.6,
                                  ),
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _isPasswordVisible =
                                              !_isPasswordVisible,
                                    ),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(255, 255, 255, 0.3),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(255, 255, 255, 0.3),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator:
                                (value) =>
                                    value != null && value.length >= 6
                                        ? null
                                        : 'Min 6 characters',
                          ),

                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.15,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: const Color.fromRGBO(
                                    255,
                                    255,
                                    255,
                                    0.3,
                                  ),
                                ),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),

                          const SizedBox(height: 16),
                          TextButton(
                            onPressed:
                                () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                ),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color.fromRGBO(
                                255,
                                255,
                                255,
                                0.8,
                              ),
                            ),
                            child: const Text("Don't have an account? Sign Up"),
                          ),
                        ],
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
