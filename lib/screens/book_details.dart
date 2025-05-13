import 'package:audiobook_e_library/core/style/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/screens/auth/auth_wrapper.dart';
import '../core/supabase_config.dart';
import 'book_listen.dart';
import 'book_read.dart';

class BooksDetails extends StatefulWidget {
  final Map<String, dynamic> book;

  const BooksDetails({super.key, required this.book});

  @override
  State<BooksDetails> createState() => _BooksDetailsState();
}

class _BooksDetailsState extends State<BooksDetails> {
  bool _isBookmarked = false;
  double _userRating = 0;
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
    _checkIfUserHasRated();
    updateBookRatings();
  }

  Future<void> _checkIfBookmarked() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('user_saved_books')
            .select()
            .eq('user_id', user.id)
            .eq('book_id', widget.book['id'])
            .maybeSingle();

        if (response != null) {
          setState(() {
            _isBookmarked = true;
          });
        }
      } catch (e) {
        print('Error checking bookmark: $e');
      }
    }
  }

  Future<void> _checkIfUserHasRated() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('user_ratings')
            .select()
            .eq('user_id', user.id)
            .eq('book_id', widget.book['id'])
            .maybeSingle();

        if (response != null) {
          setState(() {
            _userRating = (response['rating'] as num).toDouble();
            _hasRated = true;
          });
        }
      } catch (e) {
        print('Error checking user rating: $e');
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        if (_isBookmarked) {
          await Supabase.instance.client
              .from('user_saved_books')
              .delete()
              .eq('user_id', user.id)
              .eq('book_id', widget.book['id']);
        } else {
          await Supabase.instance.client
              .from('user_saved_books')
              .insert({
            'user_id': user.id,
            'book_id': widget.book['id'],
          });
        }
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
      } catch (e) {
        print('Error toggling bookmark: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to bookmark books.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  Future<void> _handleRating(double rating) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userRating = rating;
      });
      try {
        if (_hasRated) {
          //update
          await Supabase.instance.client.from('user_ratings').update({
            'rating': rating,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', user.id).eq('book_id', widget.book['id']);
        } else {
          //insert
          await Supabase.instance.client.from('user_ratings').insert({
            'user_id': user.id,
            'book_id': widget.book['id'],
            'rating': rating,
          });
          setState(() {
            _hasRated = true;
          });
        }

        //update average book rating
        await updateBookRatings();
      } catch (e) {
        print('Error submitting rating: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit rating.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to rate this book.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  Future<void> updateBookRatings() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.rpc('update_book_ratings');
      print('Book ratings updated successfully');
    } catch (e) {
      print('Failed to update book ratings: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.planeColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.black87, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      IconButton(
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: Colors.black87,
                          size: 28,
                        ),
                        onPressed: _toggleBookmark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      widget.book['imagePath'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 40,
                              color: Colors.grey,
                            ));
                      },
                    ),
                  ),
                ),
                Text(
                  widget.book['bookname'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  "By ${widget.book['authorName']}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        initialRating: widget.book['rating'] ??
                            0.0, //use the book's average rating
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 22,
                        itemPadding:
                        const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (value) {},
                        ignoreGestures:
                        true, // Display only, user cannot change here
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (widget.book['rating'] ?? 'N/A')
                            .toString(), //show the average rating
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                // New Rating Bar for User Rating
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Column(
                    children: [
                      const Text(
                        "Your Rating:",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      RatingBar.builder(
                        initialRating: _userRating,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30,
                        itemPadding:
                        const EdgeInsets.symmetric(horizontal: 8.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        onRatingUpdate:
                        _handleRating, //call the _handleRating function
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  child: Divider(color: Colors.grey, thickness: 1),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        top: 10, left: 30, right: 30, bottom: 160),
                    // Increased bottom padding
                    child: Text(
                      widget.book['description'] ??
                          "No description available.",
                      style: const TextStyle(
                          fontSize: 16,
                          letterSpacing: 1.1,
                          height: 1.5,
                          color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40, // Increased the bottom value to shift buttons up
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (widget.book['pdfPath'] != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final user = supabase.auth.currentUser;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BooksReadHorizontal(book: widget.book)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please sign in to read the book.')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthGate()),
                        );
                      }
                    },
                    icon: const Icon(Icons.book_rounded, size: 24),
                    label: const Text(
                      "Read Now",
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6a5acd),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                  ),
                if (widget.book['audioPaths'] != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final user = supabase.auth.currentUser;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BooksListen(book: widget.book)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please sign in to listen to the book.')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthGate()),
                        );
                      }
                    },
                    icon: const Icon(Icons.headphones_rounded, size: 24),
                    label: const Text(
                      "Listen",
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff008b8b),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

