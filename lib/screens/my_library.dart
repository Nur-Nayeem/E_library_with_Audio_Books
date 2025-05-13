import 'package:audiobook_e_library/core/style/app_styles.dart';
import 'package:flutter/material.dart';
import '../core/style/new_card.dart'; // Import the separate card widget
import '../core/supabase_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/theme/theme_provider.dart'; // Import your theme provider

class SavedBooksPage extends ConsumerStatefulWidget { // Change to ConsumerStatefulWidget
  const SavedBooksPage({super.key});

  @override
  ConsumerState<SavedBooksPage> createState() => _SavedBooksPageState();
}

class _SavedBooksPageState extends ConsumerState<SavedBooksPage> {
  List<Map<String, dynamic>> savedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSavedBooks();
  }

  Future<void> fetchSavedBooks() async {
    try {
      // Get the current user ID
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch saved books by joining the tables
      final response = await supabase
          .from('user_saved_books')
          .select('''
            book_id,
            books_data (*)
          ''')
          .eq('user_id', userId);

      if (response.isEmpty) {
        setState(() {
          savedBooks = [];
          isLoading = false;
        });
        return;
      }

      // Extract the books_data from the response
      final books = response.map((item) => item['books_data'] as Map<String, dynamic>).toList();

      setState(() {
        savedBooks = books;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching saved books: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;
    fetchSavedBooks();
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : AppStyles.bgColor, // Apply theme
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[800] : AppStyles.bgColor, // Apply theme
        title: Text(
          'My Saved Books',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87, // Apply theme
          ),
        ),
        elevation: 1,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87), // Apply theme
      ),
      body: isLoading
          ?  Center(child: CircularProgressIndicator(color: isDarkMode ? Colors.white : null,)) // Apply theme
          : savedBooks.isEmpty
          ?  Center(child: Text('No saved books found', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),)) // Apply theme
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Adjust as needed
            childAspectRatio: 0.7, // Adjust as needed
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: savedBooks.length,
          itemBuilder: (context, index) {
            final book = savedBooks[index];
            return BookGridCard(book: book); // Use the separate card widget
          },
        ),
      ),
    );
  }
}

