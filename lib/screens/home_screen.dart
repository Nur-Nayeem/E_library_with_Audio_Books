import 'dart:async';
import 'package:audiobook_e_library/screens/book_details.dart';
import 'package:audiobook_e_library/screens/book_listing_screen_see_more_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/book-model/data.dart';
import '../auth/screens/auth/auth_wrapper.dart';
import '../auth/screens/auth/fetch_profile.dart';
import '../auth/screens/auth/user_profile.dart';
import '../core/book_list/auto_swaip_books.dart';
import '../core/book_list/trending_book_cards_widget.dart';
import '../core/book_list/fetch_books.dart';
import '../core/style/app_double_text.dart';
import '../core/style/app_styles.dart';
import '../core/style/book_card.dart';
import 'audiobook_listing_see_more_screen.dart';
import 'category_books_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/theme/theme_provider.dart'; // Import your theme provider

class ExploreScreen extends ConsumerStatefulWidget { // Use ConsumerStatefulWidget
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late Future<List<Booksdata>> _popularBooksFuture;
  late Future<List<Booksdata>> _audioBooksFuture;
  late Future<List<Booksdata>> _trendingBooksFuture;
  late Future<List<Booksdata>> _allBooksFuture;
  late Future<List<Booksdata>> _featureBooksFuture;
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
  ];

  @override
  void initState() {
    super.initState();
    _popularBooksFuture = fetchPopularBooks();
    _audioBooksFuture = fetchAudioBooks();
    _trendingBooksFuture = fetchTrendingBooks();
    _allBooksFuture = fetchAllBooks().then((books) {
      _allBooks = books;
      return books;
    });
    _featureBooksFuture = fetchFeaturesBook();
    _profileDataFuture = loadProfileData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = _allBooks
            .where((book) =>
        book.bookname.toLowerCase().contains(query.toLowerCase()) ||
            (book.authorName.toLowerCase().contains(query.toLowerCase()) ??
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
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : AppStyles.bgColor.withOpacity(0.8), // Apply theme
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : AppStyles.bgColor.withOpacity(0.8), // Apply theme
        elevation: 0,
        leading: Padding( // Consider adding padding for better visual appearance
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo/icon.png', // Make sure the path to your image is correct
          ),
        ),
        title: Text(
          "এক্সপ্লোর",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87, // Apply theme
          ),
        ),
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
                      return  Text(
                        "Hi, Loading...",
                        style: TextStyle(fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black87), // Apply theme
                      );
                    } else if (snapshot.hasError) {
                      return  Text(
                        "Hi, Error",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      );
                    } else if (snapshot.hasData && snapshot.data!.containsKey('name')) {
                      return  Text(
                        "Hi, ${user == null ? "Sign in here" :  snapshot.data!['name']}",
                        style: TextStyle(fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black87), // Apply theme
                      );
                    } else {
                      return  Text(
                        "Hi, User",
                        style: TextStyle(fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black87), // Apply theme
                      );
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserProfile()),
                    );
                  }
                  else{
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthGate()),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FutureBuilder<Map<String, String>>(
                    future: _profileDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return  CircleAvatar(
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
                        return  CircleAvatar(
                          backgroundColor: AppStyles.userBg,
                          child:  Icon(Icons.person, color: isDarkMode ? Colors.white: AppStyles.userIcon), // Apply theme
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
                      :  Center(child: Text("কোন বই খোজে পাওয়া যায়নি", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),)) // Apply theme
                else ...[
                  AppDoubleText(
                    bigText: "ফিচারড",
                    smallText: "আরো দেখুন",
                    func: () async {
                      List<Booksdata> trendingBooks = await _featureBooksFuture;
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('কোন ফিচারড বই খোজে পাওয়া যায়নি')),
                          );
                        }
                      }
                    },
                  ),
                  FutureBuilder<List<Booksdata>>(
                    future: _featureBooksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return  Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red),));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return  Center(child: Text('কোন ফিচারড বই খোজে পাওয়া যায়নি', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),)); // Apply theme
                      } else {
                        return AutoSwiper(
                          book: snapshot.data!.take(3).toList(),);
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('কোন ট্রেন্ডিং বই খোজে পাওয়া যায়নি')),
                          );
                        }
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
                          return  Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red),));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return  Center(child: Text('কোন বই খোজে পাওয়া যায়নি', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),)); // Apply theme
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
                        color: isDarkMode ? Colors.white : Colors.black87, // Apply theme
                      ),
                    ),),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
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
                              foregroundColor: isDarkMode ? Colors.white : Colors.black87, // Apply theme
                              backgroundColor: isDarkMode? Colors.grey[850] : Colors.grey.shade400,
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

                  //populer section
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('কোন পপুলার বই খোজে পাওয়া যায়নি')),
                          );
                        }
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
                          return  Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red),));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('কোন পপুলার বই খোজে পাওয়া যায়নি'));
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.take(4).length,
                            itemBuilder: (context, index) {
                              return Books(
                                  book: snapshot.data![index].toMap(), typeed: "");
                            },
                          );
                        }
                      },
                    ),
                  ),




                  const SizedBox(height: 20),

                  //populer section
                  AppDoubleText(
                    bigText: "অডিও বই",
                    smallText: "আরো দেখুন",
                    func: () async {
                      List<Booksdata> popularBooks =
                      await _audioBooksFuture;
                      if (popularBooks.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudioBooksListScreen(
                                audioBooks: popularBooks, category: "অডিও বই"),
                          ),
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('কোন অডিও বই খোজে পাওয়া যায়নি')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder<List<Booksdata>>(
                      future: _audioBooksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return  Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red),));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('কোন অডিও বই খোজে পাওয়া যায়নি'));
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.take(4).length,
                            itemBuilder: (context, index) {

                              return Books(
                                  book: snapshot.data![index].toMap(), typeed: "audio");
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
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850]!.withOpacity(0.7) : Colors.grey.shade100.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearchResults,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: "পছন্দের বই খুজুন...",
          hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index].toMap();
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          child: ListTile(
            leading: SizedBox(
              width: 50,
              height: 70,
              child: Image.network(
                book['imagePath'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return  Icon(Icons.book, size: 40, color: isDarkMode ? Colors.white : Colors.black87,);
                },
              ),
            ),
            title: Text(book['bookname'], style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),),
            subtitle: Text(
              book['authorName'] ?? 'Unknown Author',
              style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600),
            ),
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

