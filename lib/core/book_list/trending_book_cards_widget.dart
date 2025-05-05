import 'package:flutter/material.dart';
import '../../screens/book_details.dart';
import 'fetch_books.dart';

// Separate widget for displaying a single book (trending_book_cards_widget.dart)
class TrendingBookCards extends StatelessWidget {
  final Map<String, dynamic> book;
  final bool wholeScreen;

  const TrendingBookCards({
    super.key,
    required this.book,
    this.wholeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.33,
      height: 120,
      child: Container(
        margin: EdgeInsets.only(right: wholeScreen == true ? 0 : 16),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(0.7), // Added opacity here
            borderRadius: BorderRadius.circular(5),
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Image.network(
                    book['imagePath'],
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        book['bookname'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book['authorName'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            "${book['rating']}",
                            style: const TextStyle(fontSize: 10),
                          ),
                          const Spacer(),
                          const Icon(Icons.bookmark_border_outlined, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}