
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/services/api_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _apiService = ApiService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    _setLoading(true);
    final success = await _apiService.signInWithGoogle();
    _setLoading(false);
    if (success) {
      if (!mounted) return;
      context.go('/gender');
    }
  }

  Future<void> _handleFacebookSignIn() async {
    _setLoading(true);
    final success = await _apiService.signInWithFacebook();
    _setLoading(false);
    if (success) {
      if (!mounted) return;
      context.go('/gender');
    }
  }

  Future<void> _handleEmailSignUp() async {
    _setLoading(true);
    final success = await _apiService.signUpWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    _setLoading(false);
    if (success) {
      if (!mounted) return;
      context.go('/gender');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade200,
                  Colors.blue.shade200,
                ],
              ),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.solidCommentDots,
                              size: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Welcome to Chat App',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pacifico(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Find your perfect match and connect with people near you.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email or Phone Number',
                            filled: true,
                            fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton(
                          onPressed: _handleEmailSignUp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton.icon(
                          onPressed: _handleGoogleSignIn,
                          icon: const FaIcon(FontAwesomeIcons.google),
                          label: const Text('Sign in with Google'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton.icon(
                          onPressed: _handleFacebookSignIn,
                          icon: const FaIcon(FontAwesomeIcons.facebook),
                          label: const Text('Sign in with Facebook'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue.shade800,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40), // Added some bottom padding
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
