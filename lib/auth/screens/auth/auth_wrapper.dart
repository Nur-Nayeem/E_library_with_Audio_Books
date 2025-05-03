import 'package:audiobook_e_library/auth/screens/auth/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthStateAuthenticated) {
      return const UserProfile(); // The main screen after login
    } else if (authState is AuthStateUnauthenticated) {
      // Clear the navigation stack and push to Login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Removes all previous routes
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Loading state until login screen is pushed
      );
    } else if (authState is AuthStateError) {
      return Scaffold(
        body: Center(child: Text('Auth Error: ${authState.message}')),
      );
    } else {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
