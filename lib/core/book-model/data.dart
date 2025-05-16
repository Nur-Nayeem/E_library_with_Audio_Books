class Booksdata {
  final int id;
  String bookname;
  String authorName;
  String imagePath;
  final List<String>? audioPaths;
  final String pdfPath;
  String? description;
  String? category;
  int percentageCompleted;
  // Use a private variable and getter/setter for rating
  double _rating;
  double get rating => _rating;
  set rating(double newRating) {
    _rating = double.parse(newRating.toStringAsFixed(1));
  }

  late final int? totalPages;

  Booksdata({
    required this.id,
    required this.authorName,
    required this.bookname,
    required this.pdfPath,
    this.audioPaths,
    this.description,
    this.category,
    required this.percentageCompleted,
    required this.imagePath,
    required double rating, // Take rating as a double
    this.totalPages,
  }) : _rating = double.parse(rating.toStringAsFixed(1));  // Ensure 1 decimal place here

  factory Booksdata.fromMap(Map<String, dynamic> map) {
    return Booksdata(
      id: map['id'] as int,
      bookname: map['bookname'] as String,
      authorName: map['author_name'] as String,
      imagePath: map['image_path'] as String,
      audioPaths: (map['audio_paths'] as List?)?.map((e) => e.toString()).toList(),
      pdfPath: map['pdf_path'] as String,
      description: map['description'] as String?,
      category: map['cetegory'] as String?,
      percentageCompleted: map['percentage_completed'] as int? ?? 0,
      // Format rating here as well to handle data from storage
      rating: double.parse((map['rating'] as num).toDouble().toStringAsFixed(1)),
      totalPages: map['total_pages'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookname': bookname,
      'authorName': authorName,
      'imagePath': imagePath,
      'audioPaths': audioPaths,
      'pdfPath': pdfPath,
      'description': description,
      'cetegory': category,
      'percentageCompleted': percentageCompleted,
      'rating': rating, // Use the getter
      'totalPages': totalPages,
    };
  }
}
