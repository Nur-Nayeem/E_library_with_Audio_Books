// core/book_list/not_used_book_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../screens/book_details.dart';

class Books extends StatelessWidget {
  final Map<String, dynamic> book;
  final String typeed;

  const Books({super.key, required this.book, required this.typeed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(book['audioPath']);

    // final hasAudio = book['audioPath'] != null;
    final hasAudio = typeed == "audio" ? true : false ;

    return Container(
      width: size.width * 0.28,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.2,
            blurRadius: 1,
            offset: const Offset(0, 0.5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BooksDetails(book: book)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      book['imagePath'],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (hasAudio)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: Icon(
                          Icons.headphones,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['bookname'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    book['authorName'],
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: (book['rating'] as num?)?.toDouble() ?? 0.0,
                        itemBuilder: (context, index) =>
                        const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 10.0,
                        unratedColor: Colors.grey[300],
                      ),
                      if (typeed == "saved") ...[
                        const Spacer(),
                        const Icon(Icons.bookmark_added, size: 22),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
