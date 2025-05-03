// main.dart
import 'package:audiobook_e_library/screens/bottom_nav_bar.dart';
import 'package:audiobook_e_library/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/screens/auth/login_screen.dart';
import 'auth/screens/auth/signup_screen.dart';
import 'auth/screens/auth/user_profile.dart';
import 'core/supabase_config.dart';


// Main App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E Library With Audio Book',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const BottomNavBar(),
      routes: {
//const BottomNavBar(),
        'login': (context) => const LoginScreen(),
        'signup': (context) => const SignupScreen(),
        'home': (context) => const ExploreScreen(),
        //'profile': (context) => const ProfileUpdateScreen(), // Add the profile route
        'user-profile': (context) => const UserProfile(), // Add the profile route
      },

    );
  }
}
