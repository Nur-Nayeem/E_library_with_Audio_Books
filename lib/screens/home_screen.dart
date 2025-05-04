import 'dart:async';

import 'package:audiobook_e_library/screens/book_details.dart';
import 'package:audiobook_e_library/screens/book_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/book-model/data.dart';
import '../auth/screens/auth/auth_wrapper.dart';
import '../auth/screens/auth/fetch_profile.dart';
import '../core/book_list/auto_swaip_books.dart';
import '../core/book_list/trending_book_cards_widget.dart';
import '../core/book_list/fetch_books.dart';
import '../core/style/app_double_text.dart';
import '../core/style/book_card.dart';
import 'category_books_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<Booksdata>> _popularBooksFuture;
  late Future<List<Booksdata>> _trendingBooksFuture;
  late Future<List<Booksdata>> _allBooksFuture;
  List<Booksdata> _allBooks = [];
  List<Booksdata> _searchResults = [];
  late Future<Map<String, String>> _profileDataFuture;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Novel',
    'Poetry',
    'Adventure',
    'Fiction',
    'Mystery',
    'Thriller',
    'Romance',
    'Historical Fiction',
    'All',
    // Add more categories as needed
  ];

  @override
  void initState() {
    super.initState();
    _popularBooksFuture = fetchPopularBooks();
    _trendingBooksFuture = fetchTrendingBooks();
    _allBooksFuture = fetchAllBooks().then((books) {
      _allBooks = books;
      return books;
    });
    _profileDataFuture = loadProfileData();
  }

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = _allBooks
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

  void _navigateToCategoryBooks(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryBooksScreen(selectedCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeedf2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: Text(
          "এক্সপ্লোর",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        //profile image:
        //profile image:
      actions: [
        Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            child: FutureBuilder<Map<String, String>>(
              future: _profileDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "Hi, Loading...",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  );
                } else if (snapshot.hasError) {
                  return const Text(
                    "Hi, Error",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                  );
                } else if (snapshot.hasData && snapshot.data!.containsKey('name')) {
                  return Text(
                    "Hi, ${snapshot.data!['name']}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  );
                } else {
                  return const Text(
                    "Hi, User",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  );
                }
              },
            ),
          ),
          GestureDetector( // Wrap the CircleAvatar with GestureDetector
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthGate()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FutureBuilder<Map<String, String>>(
                future: _profileDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      backgroundColor: Colors.grey,
                    );
                  } else if (snapshot.hasError) {
                    return const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.error_outline, color: Colors.white),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data!.containsKey('image_url') &&
                      snapshot.data!['image_url']!.isNotEmpty) {
                    return CircleAvatar(
                      backgroundImage:
                      NetworkImage(snapshot.data!['image_url']!),
                    );
                  } else {
                    return const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.black87),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                if (_searchController.text.isNotEmpty)
                  _searchResults.isNotEmpty
                      ? _buildSearchResultsList()
                      : const Center(child: Text("কোন বই খোজে পাওয়া যায়নি"))
                else ...[
                  AppDoubleText(
                    bigText: "ফিচারড",
                    smallText: "আরো দেখুন",
                    func: () async {
                      List<Booksdata> trendingBooks = await _allBooksFuture;
                      if (trendingBooks.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BooksListScreen(
                                popularBooks: trendingBooks,
                                category: "ফিচারড"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('কোন ফিচারড বই খোজে পাওয়া যায়নি')),
                        );
                      }
                    },
                  ),
                  FutureBuilder<List<Booksdata>>(
                    future: _popularBooksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('কোন ফিচারড বই খোজে পাওয়া যায়নি'));
                      } else {
                        return AutoSwiper(
                            book: snapshot.data!.take(3).toList());
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  AppDoubleText(
                    bigText: "ট্রেন্ডিং",
                    smallText: "আরো দেখুন",
                    func: () async {
                      List<Booksdata> trendingBooks = await _trendingBooksFuture;
                      if (trendingBooks.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BooksListScreen(
                                popularBooks: trendingBooks,
                                category: "ট্রেন্ডিং"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('কোন ট্রেন্ডিং বই খোজে পাওয়া যায়নি')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder<List<Booksdata>>(
                      future: _trendingBooksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('কোন বই খোজে পাওয়া যায়নি'));
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.take(4).length,
                            itemBuilder: (context, index) {
                              return TrendingBookCards(
                                  book: snapshot.data![index].toMap());
                            },
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child:  Text(

                      "কেটাগরি",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),),
                  const SizedBox(height: 10),
                  // Category Buttons Section
                  SizedBox(
                    height: 40, // Adjust height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _navigateToCategoryBooks(category),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.grey.shade300,
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



                  const SizedBox(height: 20),
                  AppDoubleText(
                    bigText: "পপুলার",
                    smallText: "আরো দেখুন",
                    func: () async {
                      List<Booksdata> popularBooks =
                      await _popularBooksFuture;
                      if (popularBooks.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BooksListScreen(
                                popularBooks: popularBooks, category: "পপুলার"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('কোন পপুলার বই খোজে পাওয়া যায়নি')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder<List<Booksdata>>(
                      future: _popularBooksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('কোন পপুলার বই খোজে পাওয়া যায়নি'));
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.take(4).length,
                            itemBuilder: (context, index) {
                              return Books(
                                  book: snapshot.data![index].toMap());
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearchResults,
        decoration: InputDecoration(
          hintText: "পছন্দের বই খুজুন...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index].toMap();
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: SizedBox(
              width: 50,
              height: 70,
              child: Image.network(
                book['imagePath'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.book, size: 40);
                },
              ),
            ),
            title: Text(book['bookname']),
            subtitle: Text(book['authorName'] ?? 'Unknown Author'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BooksDetails(
                      book: book),
                ),
              );
            },
          ),
        );
      },
    );
  }
}