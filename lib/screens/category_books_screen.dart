import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/theme/theme_provider.dart'; // Import your theme provider

import '../../../core/book-model/data.dart';
import '../core/book_list/fetch_books.dart';
import '../core/style/app_styles.dart';
import '../core/style/book_card.dart'; // You might need other card widgets// Import your data fetching functions

class CategoryBooksScreen extends ConsumerStatefulWidget {
  final String selectedCategory;

  const CategoryBooksScreen({super.key, required this.selectedCategory});

  @override
  ConsumerState<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends ConsumerState<CategoryBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Booksdata> _categoryBooks = [];
  List<Booksdata> _searchResults = [];
  final List<String> _categories = [
    'All',
    'Novel',
    'Poetry',
    'Adventure',
    'Fiction',
    'Mystery',
    'Thriller',
    'Romance',
    'Historical Fiction',
    // Add more categories as needed
  ];
  late String _currentCategory;
  late Future<List<Booksdata>> _categoryBooksFuture;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
    _categoryBooksFuture = _fetchBooksByCategory(_currentCategory);
  }

  Future<List<Booksdata>> _fetchBooksByCategory(String category) async {
    if (category != 'All') {
      List<Booksdata> allBooks =
      await fetchAllBooks(); // Ensure you have this function
      return allBooks
          .where((book) =>
      (book.category?.toLowerCase() == category.toLowerCase()))
          .toList();
    } else {
      List<Booksdata> allBooks =
      await fetchAllBooks(); // Ensure you have this function
      return allBooks.toList();
    }
  }

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = _categoryBooks
            .where((book) =>
        book.bookname.toLowerCase().contains(query.toLowerCase()) ||
            (book.authorName?.toLowerCase().contains(query.toLowerCase()) ??
                false))
            .toList();
      });
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  void _changeCategory(String category) {
    setState(() {
      _currentCategory = category;
      _searchController.clear();
      _searchResults.clear();
      _categoryBooksFuture = _fetchBooksByCategory(_currentCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : AppStyles.bgColor,
        elevation: 0,
        title: Text(
          _currentCategory,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView( // Use ListView as the outer widget
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _changeCategory(category),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: _currentCategory == category
                          ? Colors.white
                          : isDarkMode ? Colors.white : Colors.black87,
                      backgroundColor: _currentCategory == category
                          ? Theme.of(context).primaryColor
                          : isDarkMode ? Colors.grey[850] : Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Booksdata>>(
              future: _categoryBooksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: isDarkMode ? Colors.white : null));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No books found in this category.',
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87)));
                } else {
                  _categoryBooks = snapshot.data!;
                  return _searchController.text.isNotEmpty
                      ? _buildSearchResultsGrid()
                      : _buildCategoryBooksGrid();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]! : Colors.grey.shade100.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearchResults,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: "Search in ${_currentCategory}...",
          hintStyle:
          TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600),
          prefixIcon:
          Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildCategoryBooksGrid() {
    return GridView.builder(
      shrinkWrap: true, // Important for embedding in ListView
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the GridView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _categoryBooks.length,
      itemBuilder: (context, index) {
        return Books(book: _categoryBooks[index].toMap(), typeed: "");
      },
    );
  }

  Widget _buildSearchResultsGrid() {
    return GridView.builder(
      shrinkWrap: true, // Important for embedding in ListView
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the GridView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return Books(book: _searchResults[index].toMap(), typeed: "");
      },
    );
  }
}