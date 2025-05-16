
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/book-model/data.dart';

// Global variable (use with caution, consider better state management)
List<Map<String, dynamic>> globalTrendingBooks = [];

List<Map<String, dynamic>> globalPopularBooks = [];

List<Map<String, dynamic>> globalAudioBooks = [];

List<Map<String, dynamic>> AllBooks = [];

List<Map<String, dynamic>> AllFeatureBooks = [];





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

Future<List<Booksdata>> fetchFeaturesBook() async {
  final oneMonthAgo = DateTime.now().toUtc().subtract(const Duration(days: 30));
  final oneMonthAgoString = oneMonthAgo.toIso8601String();

  final response = await Supabase.instance.client
      .from('books_data')
      .select()
      .gte('uploaded_at', oneMonthAgoString); // Assuming you have a 'created_at' column

  final featureBooks =
  (response as List).map((e) => Booksdata.fromMap(e)).toList();
  print(featureBooks);

  AllFeatureBooks = featureBooks.map((book) => book.toMap()).toList();

  return featureBooks;
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

Future<List<Booksdata>> fetchAudioBooks() async {
  final response = await Supabase.instance.client
      .from('books_data')
      .select()
      .neq('audio_paths', []);

final audioBooks =
(response as List).map((e) => Booksdata.fromMap(e)).toList();

globalAudioBooks = audioBooks.map((book) => book.toMap()).toList();
print(globalAudioBooks);

return audioBooks;
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
