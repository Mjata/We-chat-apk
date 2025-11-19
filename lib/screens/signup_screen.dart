import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/services/api_service.dart';
import 'dart:developer' as developer;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        developer.log("Firebase Email/Pass Sign-Up successful. User: ${userCredential.user!.uid}", name: 'SignupScreen');

        try {
          await _apiService.setupNewUser();
          developer.log("Backend setupNewUser successful.", name: 'SignupScreen');
          if (mounted) {
            context.go('/gender');
          }
        } catch (e) {
          developer.log("Error calling setupNewUser: $e", error: e, name: 'SignupScreen');
          await _auth.signOut();
          if (mounted) {
            _showErrorSnackBar("Failed to set up your user profile on the server. Please try again.");
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      developer.log("Email/Pass Sign-Up failed: ${e.code}", error: e, name: 'SignupScreen');
      String message = "Sign-up failed. Please try again.";
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      }
      if (mounted) {
        _showErrorSnackBar(message);
      }
    } on TypeError catch (e) {
        developer.log(
            'A TypeError occurred during sign-up. This might be a data parsing issue.',
            error: e,
            stackTrace: e.stackTrace,
            name: 'SignupScreen',
        );
        if (mounted) {
            _showErrorSnackBar("A data processing error occurred. Please check the logs.");
        }
    } catch (e) {
      developer.log("An unexpected error occurred during sign-up: $e", error: e, name: 'SignupScreen');
      if (mounted) {
        _showErrorSnackBar("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('Google Sign-In cancelled by user.', name: 'SignupScreen');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        developer.log("Firebase Google Sign-In successful. User: ${userCredential.user!.displayName}", name: 'SignupScreen');

        if (userCredential.additionalUserInfo?.isNewUser == true) {
          developer.log("New user detected. Calling setupNewUser on backend...", name: 'SignupScreen');
          try {
            await _apiService.setupNewUser();
            developer.log("Backend setupNewUser successful.", name: 'SignupScreen');
          } catch (e) {
            developer.log("Error calling setupNewUser: $e", error: e, name: 'SignupScreen');
            await _auth.signOut(); 
            if (mounted) {
              _showErrorSnackBar("Failed to set up user profile on the server. Please try again.");
            }
            setState(() {_isLoading = false;});
            return;
          }
        } else {
          developer.log("Existing user logged in.", name: 'SignupScreen');
        }
        
        if (mounted) {
          context.go('/gender');
        }
      }
    } on TypeError catch (e) {
        developer.log(
            'A TypeError occurred during Google sign-in. This might be a data parsing issue.',
            error: e,
            stackTrace: e.stackTrace,
            name: 'SignupScreen',
        );
        if (mounted) {
            _showErrorSnackBar("A data processing error occurred. Please check the logs.");
        }
    } catch (e) {
      developer.log("Google Sign-In failed: $e", error: e, name: 'SignupScreen');
      if (mounted) {
        _showErrorSnackBar("Google Sign-In failed. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(204),
              Theme.of(context).colorScheme.secondary.withAlpha(204),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSignupCard(context),
                      const SizedBox(height: 30),
                      _buildSocialLoginButtons(context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Account',
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUpWithEmailAndPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => context.go('/welcome'),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Or continue with',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
              label: const Text('Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
