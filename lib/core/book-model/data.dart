class Booksdata {
  String bookname;
  String authorName;
  String imagePath;
  final List<String>? audioPaths;
  final String pdfPath;
  String? description;
  String? category;
  int percentageCompleted;
  double rating;
  late final int? totalPages;

  Booksdata({
    required this.authorName,
    required this.bookname,
    required this.pdfPath,
    this.audioPaths,
    this.description,
    this.category,
    required this.percentageCompleted,
    required this.imagePath,
    required this.rating,
    this.totalPages,
  });

  factory Booksdata.fromMap(Map<String, dynamic> map) {
    return Booksdata(
      bookname: map['bookname'] as String,
      authorName: map['author_name'] as String,
      imagePath: map['image_path'] as String,
      audioPaths: (map['audio_paths'] as List?)?.map((e) => e.toString()).toList(),
      pdfPath: map['pdf_path'] as String,
      description: map['description'] as String?,
      category: map['cetegory'] as String?,
      percentageCompleted: map['percentage_completed'] as int? ?? 0,
      rating: (map['rating'] as num).toDouble(),
      totalPages: map['total_pages'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookname': bookname,
      'authorName': authorName,
      'imagePath': imagePath,
      'audioPaths': audioPaths,
      'pdfPath': pdfPath,
      'description': description,
      'cetegory': category,
      'percentageCompleted': percentageCompleted,
      'rating': rating,
      'totalPages': totalPages,
    };
  }
}
