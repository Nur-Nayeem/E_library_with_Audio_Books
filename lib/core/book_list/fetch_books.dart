
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/book-model/data.dart';

// Global variable (use with caution, consider better state management)
List<Map<String, dynamic>> globalTrendingBooks = [];

List<Map<String, dynamic>> globalPopularBooks = [];

List<Map<String, dynamic>> AllBooks = [];



// Separate file for fetching books (fetch_books.dart)
Future<List<Booksdata>> fetchAllBooks() async {
final response = await Supabase.instance.client
    .from('books_data')
    .select();

final allTheBooks =
(response as List).map((e) => Booksdata.fromMap(e)).toList();
print(allTheBooks);

AllBooks = allTheBooks.map((book) => book.toMap()).toList();

return allTheBooks;
}

Future<List<Booksdata>> fetchPopularBooks() async {
final response = await Supabase.instance.client
    .from('books_data')
    .select()
    .eq('highlight', 'populer');

final popularBooks =
(response as List).map((e) => Booksdata.fromMap(e)).toList();

globalPopularBooks = popularBooks.map((book) => book.toMap()).toList();
print(globalPopularBooks);

return popularBooks;
}

Future<List<Booksdata>> fetchTrendingBooks() async {
final response = await Supabase.instance.client
    .from('books_data')
    .select()
    .eq('highlight', 'trending'); // Corrected category

final trendingBooks =
(response as List).map((e) => Booksdata.fromMap(e)).toList();
print(trendingBooks);

globalTrendingBooks = trendingBooks.map((book) => book.toMap()).toList();

return trendingBooks;
}
