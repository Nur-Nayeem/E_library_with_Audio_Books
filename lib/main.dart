import 'package:audiobook_e_library/auth/screens/auth/auth_wrapper.dart';
import 'package:audiobook_e_library/screens/bottom_nav_bar.dart';
import 'package:audiobook_e_library/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/screens/auth/login_screen.dart';
import 'auth/screens/auth/signup_screen.dart';
import 'auth/screens/auth/user_profile.dart';
import 'core/supabase_config.dart';
import 'core/theme/theme_provider.dart';

// Main App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    return MaterialApp(
      title: 'E Library With Audio Book',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.dark,

      ),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        // '/explore': (context) => const ExploreScreen(),
        '/home': (context) => const AuthGate(),
        '/all-books': (context) => const AllBooks(),
        '/saved-books': (context) => const SavedBooks(),
        '/user-profile': (context) => const UserProfile(), // Add the profile route
      },
      home: user != null ? const AuthGate() : const ExploreScreen(),
    );
  }
}