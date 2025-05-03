import 'package:flutter/material.dart';
import '../../screens/book_details.dart';
import 'fetch_books.dart';

// Separate widget for displaying a single book (trending_book_cards_widget.dart)
class SearchBookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final bool wholeScreen;

  const SearchBookCard({super.key, required this.book, this.wholeScreen = false});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.85,
      height: 80,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BooksDetails(
                      book: book
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book['imagePath'],
                      width: 60,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['bookname'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          book['authorName'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < 5; i++)
                              Icon(
                                i < book['rating'].floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 14,
                              ),
                            const SizedBox(width: 5),
                            Text(
                              "${book['rating']}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Icon(Icons.bookmark_border_outlined),
                ],
              ),
            ),
              ),

          ),
        ),
      );

  }
}