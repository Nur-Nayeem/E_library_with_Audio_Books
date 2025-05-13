// features/home/screens/explore_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/screens/auth/auth_wrapper.dart';
import '../auth/screens/auth/user_profile.dart';
import 'category_books_screen.dart';
import 'home_screen.dart';
import 'audio_book_listing_main.dart';


class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const ExploreScreen(),
    const CategoryBooksScreen(selectedCategory: 'All',),
    const AudioBooksListScreen(selectedCategory: 'Audio Books',),
    const UserProfile(),
  ];


  final List<String> _appBarTitles = <String>[
    'Home',
    'All Books',
    'Saved Books',
    'Profile',
  ];

  void _onItemTapped(int index) {
    final user = Supabase.instance.client.auth.currentUser;
    if (index == 3) {
      // Profile tab selected
      if (user == null) {
        Navigator.pushNamed(context, '/login');
        // Don't change the selected index or rebuild the body yet
        return;
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    Widget currentBody = _widgetOptions[_selectedIndex];
    bool showBottomNavBar = true;

    if (_selectedIndex == 3 && user == null) {
      // If profile is selected and user is not logged in, show nothing
      currentBody = const SizedBox.shrink();
      showBottomNavBar = false;
    } else if (_selectedIndex == 3 && user != null) {
      // If profile is selected and user is logged in, show UserProfile
      currentBody = const UserProfile();
    } else {
      currentBody = _widgetOptions[_selectedIndex];
    }

    return Scaffold(

      body: WillPopScope(
        onWillPop: () async {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return false; // Prevent default back button behavior
          }
          return true; // Allow exiting the app from the Home page
        },
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'All Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'Audio Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


class AllBooks extends StatelessWidget {
  const AllBooks({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('All Books Screen'),
    );
  }
}


class SavedBooks extends StatelessWidget {
  const SavedBooks({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Saved Books Screen'),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Page'),
    );
  }
}

class UserProfile1 extends StatelessWidget {
  const UserProfile1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('User Profile Screen'),
    );
  }
}