// popular_books_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/book-model/data.dart';
import '../core/style/app_styles.dart';
import '../core/style/book_card.dart';

class BooksListScreen extends StatelessWidget {
  final List<Booksdata> popularBooks;
  final String category;

  const BooksListScreen({super.key, required this.popularBooks, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        title: Text(
          category,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        elevation: 1,
        // iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          padding: EdgeInsets.only(top: 8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: popularBooks.length,
          itemBuilder: (context, index) {
            return Books(book: popularBooks[index].toMap());
          },
        ),
      ),
    );
  }
}