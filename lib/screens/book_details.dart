import 'package:flutter/material.dart';
import '../../../core/book-model/data.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'book_listen.dart';
import 'book_read.dart'; // RatingBar dependency

class BooksDetails extends StatelessWidget {
  final Map<String, dynamic> book;

  const BooksDetails({super.key, required this.book});

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
                            book['pdfPath'] != null ? Icons.bookmark_add_outlined : Icons.favorite_border,
                            color: Colors.black,
                            size: 35,
                          ),
                          onPressed: () {},
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
                              book['imagePath'],
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
                    book['bookname'],
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "By ${book['authorName']}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        initialRating: book['rating'],
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
                        book['rating'].toString(),
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
                          book['description'] ?? "No description available.",
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
                      if (book['pdfPath'] != null)
                        Container(
                          width: 150,
                          height: 60,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xffc44536),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BooksReadHorizontal(book: book)),
                            ),
                            child: Text(
                              "READ",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
                            ),
                          ),
                        ),
                      if (book['audioPaths'] != null)
                        SizedBox(width: 20),
                      if (book['audioPaths'] != null)
                        Container(
                          width: 150,
                          height: 60,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xffc44536),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BooksListen(book: book)),
                            ),
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
