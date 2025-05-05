import 'package:audiobook_e_library/auth/screens/auth/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../screens/bottom_nav_bar.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    Widget buildAuthScaffold({required Widget child, String? title, }) {
      return Scaffold(
        body: Container(
          // padding: const EdgeInsets.only(top: 16.0), // Add some top padding for status bar
          child: Column(
            children: [
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    if (authState is AuthStateAuthenticated) {
      return const BottomNavBar(); // The main screen after login
    } else if (authState is AuthStateUnauthenticated) {
      return buildAuthScaffold(
        title: 'Sign In / Sign Up',
        child: const LoginScreen(), // Display the LoginScreen directly
      );
    } else if (authState is AuthStateError) {
      return buildAuthScaffold(
        title: 'Authentication Error',
        child: Center(child: Text('Auth Error: ${authState.message}')),
      );
    } else {
      return buildAuthScaffold(
        title: 'Checking Authentication',
        child: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}