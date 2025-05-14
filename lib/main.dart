import 'package:audiobook_e_library/auth/screens/auth/auth_wrapper.dart';
import 'package:audiobook_e_library/screens/bottom_nav_bar.dart';
import 'package:audiobook_e_library/screens/get_started_page.dart';
import 'package:audiobook_e_library/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/screens/auth/login_screen.dart';
import 'auth/screens/auth/signup_screen.dart';
import 'auth/screens/auth/user_profile.dart';
import 'core/supabase_config.dart';
import 'core/theme/theme_provider.dart'; // Import the new screen

// Main App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  final prefs = await SharedPreferences.getInstance();
  final showGetStarted = prefs.getBool('showGetStarted') ?? true;
  runApp(ProviderScope(child: MyApp(showGetStarted: showGetStarted)));
}

class MyApp extends ConsumerStatefulWidget {
  final bool showGetStarted;
  const MyApp({super.key, required this.showGetStarted});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
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
        '/home': (context) => const AuthGate(),
        '/all-books': (context) => const AllBooks(),
        '/saved-books': (context) => const SavedBooks(),
        '/user-profile': (context) => const UserProfile(),
      },
      home: widget.showGetStarted
          ? const GetStartedScreen()
          : user != null
          ? const AuthGate()
          : const ExploreScreen(),
    );
  }
  // ExploreScreen(),
}