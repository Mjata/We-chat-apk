
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias for firebase_auth
import 'package:myapp/models/user.dart' as app_user; // Alias for your user model
import 'package:myapp/screens/welcome_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/signup_screen.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/gender_selection_screen.dart';
import 'package:myapp/screens/user_profile_screen.dart';
import 'package:myapp/screens/chat_screen.dart';

final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

final GoRouter router = GoRouter(
  // Use the stream to listen for auth changes and automatically redirect
  refreshListenable: GoRouterRefreshStream(_auth.authStateChanges()),
  
  // Initial location when the app starts
  initialLocation: '/welcome',
  
  routes: [
    // The main screen with bottom navigation. It has nested routes for each tab.
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScreen(),
      // TODO: Add nested routes for tabs if needed
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
     GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
     GoRoute(
      path: '/gender',
      builder: (context, state) => const GenderSelectionScreen(),
    ),
    // Route for the user profile, which takes a User object as an extra parameter.
    GoRoute(
        path: '/profile',
        builder: (context, state) {
            final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
            final app_user.User user = extra['user'] as app_user.User;
            final app_user.User currentUser = extra['currentUser'] as app_user.User;
            return UserProfileScreen(user: user, currentUser: currentUser);
        },
    ),

    // Route for the chat screen, which takes a conversationId and recipient User.
    GoRoute(
        path: '/chat',
        builder: (context, state) {
            final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
            final app_user.User recipient = extra['recipient'] as app_user.User;
            return ChatScreen(name: recipient.name, profilePictureUrl: recipient.profilePictureUrl);
        },
    ),
  ],

  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = _auth.currentUser != null;
    
    // Get the current location
    final String location = state.matchedLocation;

    // Define routes that are accessible without being logged in
    final bool isAuthRoute = location == '/welcome' || location == '/login' || location == '/signup';

    // If the user is not logged in and not on an auth route, redirect to welcome
    if (!loggedIn && !isAuthRoute) {
      return '/welcome';
    }

    // If the user is logged in and on an auth route, redirect to home
    if (loggedIn && isAuthRoute) {
      return '/home';
    }

    // No redirect needed
    return null;
  },
);

// This class is used to listen to the auth state changes and notify GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
