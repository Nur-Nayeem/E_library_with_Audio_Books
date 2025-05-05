import 'package:audiobook_e_library/core/style/app_styles.dart';
import 'package:flutter/material.dart';
import '../core/style/new_card.dart';
import '../core/supabase_config.dart';
import 'package:google_fonts/google_fonts.dart';
 // Import the separate card widget

class SavedBooksPage extends StatefulWidget {
  const SavedBooksPage({super.key});

  @override
  State<SavedBooksPage> createState() => _SavedBooksPageState();
}

class _SavedBooksPageState extends State<SavedBooksPage> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching saved books: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchSavedBooks();
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        title: Text(
          'My Saved Books',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedBooks.isEmpty
          ? const Center(child: Text('No saved books found'))
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