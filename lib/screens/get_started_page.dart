// lib/onboarding/get_started_screen.dart
import 'package:audiobook_e_library/auth/screens/auth/auth_wrapper.dart';
import 'package:audiobook_e_library/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Audio Book E library',
      'subtitle': 'Explore new books',
      'image': 'assets/logo/icon.png', // Replace with your image
    },
    {
      'title': 'Secure Data',
      'subtitle': 'Your security is our priority.',
      'image': 'assets/logo/logo.jpg', // Replace with your image
    },
    {
      'title': 'Easy to Use',
      'subtitle': 'Simple interface for everyone.',
      'image': 'assets/logo/supabase-logo.png', // Replace with your image
    },
  ];

  Future<void> _markAsSeenAndNavigateToExplore() async {
    print("Skip button pressed!");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showGetStarted', false);
    print("showGetStarted set to false"); // Add this line
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ExploreScreen(),
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _markAsSeenAndNavigateToExplore();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding slides
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final data = _onboardingData[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      data['title']!,
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Image.asset(
                      data['image']!,
                      height: screenHeight * 0.3,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      data['subtitle']!,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.2),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.1),
          // Bottom Section for indicators and buttons

          Positioned(
            bottom: screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => _buildPageIndicator(index == _currentPage, primaryColor),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Action Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to create account screen
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Create account',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      OutlinedButton(
                        onPressed: () {
                          // Navigate to log in screen
                          Navigator.pushNamed(context, '/login');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'By creating account or logging in, you agree to our',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => _launchURL('your_terms_url_here'), // Replace with your actual URL
                            child: Text(
                              'Terms & Conditions',
                              style: textTheme.bodySmall?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            ' and ',
                            style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => _launchURL('your_privacy_policy_url_here'), // Replace with your actual URL
                            child: Text(
                              'Privacy Policy',
                              style: textTheme.bodySmall?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Skip Button
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: TextButton(
              onPressed: _markAsSeenAndNavigateToExplore,
              child: Text(
                'Skip',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isCurrentPage, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isCurrentPage ? 20.0 : 8.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}