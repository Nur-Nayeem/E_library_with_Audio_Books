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

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
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
            .maybeSingle(); // Safe if 0 or 1 result

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

  Future<void> _toggleBookmark() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      print(
        'Attempting to toggle bookmark for user ID: ${user.id}, book ID: ${widget.book['id']}, isBookmarked: $_isBookmarked',
      );
      try {
        if (_isBookmarked) {
          final response = await Supabase.instance.client
              .from('user_saved_books')
              .delete()
              .eq('user_id', user.id)
              .eq('book_id', widget.book['id']);
          print('Delete response: $response');
        } else {
          final response = await Supabase.instance.client
              .from('user_saved_books')
              .insert({
            'user_id': user.id,
            'book_id': widget.book['id'],
          });
          print('Insert response: $response');
        }

        setState(() {
          _isBookmarked = !_isBookmarked;
        });
      } catch (e) {
        print('Error toggling bookmark: $e');
      }
    } else {
      print('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffff8ee),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black, size: 35),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        IconButton(
                          icon: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.black,
                            size: 35,
                          ),
                          onPressed: () async {
                            final user = supabase.auth.currentUser;
                            if (user != null) {
                              _toggleBookmark(); // Call the bookmark toggle function if authenticated
                            } else {
                              // Navigate to AuthGate if not authenticated
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AuthGate()),
                              );
                              // Optionally, show a message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please sign in to bookmark books.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    height: MediaQuery.of(context).size.height * 0.32,
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 25,
                                offset: Offset(8, 8),
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 25,
                                offset: Offset(-8, -8),
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              widget.book['imagePath'],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.book['bookname'],
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "By ${widget.book['authorName']}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        initialRating: widget.book['rating'],
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 25,
                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (value) {},
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.book['rating'].toString(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(24),
                    height: 8,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(top: 10, left: 40, right: 20),
                        child: Text(
                          widget.book['description'] ?? "No description available.",
                          style: TextStyle(fontSize: 20, letterSpacing: 1.5, height: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xfffff8ee).withOpacity(0.1),
                      Colors.white.withOpacity(0.3),
                      Color(0xfffff8ee).withOpacity(0.7),
                      Color(0xfffff8ee).withOpacity(0.8),
                      Color(0xfffff8ee),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.book['pdfPath'] != null)
                        Container(
                          width: 150,
                          height: 60,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xffc44536),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final user = supabase.auth.currentUser;
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BooksReadHorizontal(book: widget.book)),
                                );
                              } else {
                                // Navigate to AuthGate if not authenticated
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AuthGate()),
                                );
                                // Optionally, show a message to the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please sign in to read the book.')),
                                );
                              }
                            },
                            child: Text(
                              "READ",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
                            ),
                          ),
                        ),
                      if (widget.book['audioPaths'] != null)
                        SizedBox(width: 20),
                      if (widget.book['audioPaths'] != null)
                        Container(
                          width: 150,
                          height: 60,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xffc44536),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final user = supabase.auth.currentUser;
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BooksListen(book: widget.book)),
                                );
                              } else {
                                // Navigate to AuthGate if not authenticated
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AuthGate()),
                                );
                                // Optionally, show a message to the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please sign in to listen to the book.')),
                                );
                              }
                            },
                            child: Text(
                              "LISTEN",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
