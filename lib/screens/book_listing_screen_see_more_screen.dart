import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/theme/theme_provider.dart'; // Import your theme provider

import '../../../core/book-model/data.dart';
import '../core/style/app_styles.dart';
import '../core/style/book_card.dart';

class BooksListScreen extends ConsumerWidget { // Change to ConsumerWidget
  final List<Booksdata> popularBooks;
  final String category;

  const BooksListScreen({super.key, required this.popularBooks, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : AppStyles.bgColor, // Apply theme
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : AppStyles.bgColor, // Apply theme
        title: Text(
          category,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87, // Apply theme
          ),
        ),
        elevation: 1,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87), // Apply theme
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          padding: const EdgeInsets.only(top: 8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: popularBooks.length,
          itemBuilder: (context, index) {
            return Books(book: popularBooks[index].toMap(), typeed: "");
          },
        ),
      ),
    );
  }
}

