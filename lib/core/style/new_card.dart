import 'package:flutter/material.dart';
import '../../screens/book_details.dart';

class BookGridCard extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookGridCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Safely extract all fields with null checks
    final bookName = book['bookname'] ?? book['title'] ?? 'No Title';
    final author = book['authorName'] ?? book['author'] ?? 'Unknown Author';
    final imagePath = book['image_path'] ?? book['image_path'] ?? '';
    final rating = book['rating']?.toString() ?? 'N/A';
    final bookId = book['id']?.toString();

    return Card(
      elevation: 4,
      color: Colors.white.withOpacity(0.7), // Added opacity here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: GestureDetector(
        onTap: () {
          if (bookId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid book data')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BooksDetails(
                book: {
                  'id': bookId,
                  'bookname': bookName,
                  'authorName': author,
                  'imagePath': imagePath,
                  'rating': double.tryParse(rating) ?? 0.0,
                  'description': book['description'] ?? 'No description available',
                  'pdfPath': book['pdf_path'],
                  'audioPaths': book['audio_paths'],
                },
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(Icons.bookmark_added, size: 22,),
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