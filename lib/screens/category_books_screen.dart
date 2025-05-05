import 'package:audiobook_e_library/core/style/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/book-model/data.dart';
import '../core/book_list/fetch_books.dart';
import '../core/style/book_card.dart'; // You might need other card widgets// Import your data fetching functions

class CategoryBooksScreen extends StatefulWidget {
  final String selectedCategory;

  const CategoryBooksScreen({super.key, required this.selectedCategory});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
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
    if(category != 'All') {
      List<
          Booksdata> allBooks = await fetchAllBooks(); // Ensure you have this function
      return allBooks
          .where((book) =>
      (book.category?.toLowerCase() == category.toLowerCase()))
          .toList();
    }
    else{
      List<
          Booksdata> allBooks = await fetchAllBooks(); // Ensure you have this function
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
    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        title: Text(
          _currentCategory,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
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
                          : Colors.black87,
                      backgroundColor: _currentCategory == category
                          ? Theme.of(context).primaryColor // Customize active color
                          : Colors.grey.shade200,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Booksdata>>(
                future: _categoryBooksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No books found in this category.'));
                  } else {
                    _categoryBooks = snapshot.data!;
                    return _searchController.text.isNotEmpty
                        ? _buildSearchResultsGrid()
                        : _buildCategoryBooksGrid();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearchResults,
        decoration: InputDecoration(
          hintText: "Search in ${_currentCategory}...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildCategoryBooksGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust as needed
        childAspectRatio: 0.65, // Adjust as needed
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _categoryBooks.length,
      itemBuilder: (context, index) {
        return Books(book: _categoryBooks[index].toMap()); // Or your preferred book card
      },
    );
  }

  Widget _buildSearchResultsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust as needed
        childAspectRatio: 0.65, // Adjust as needed
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return Books(book: _searchResults[index].toMap()); // Or your preferred book card
      },
    );
  }
}