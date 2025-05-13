import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/theme/theme_provider.dart'; // Import your theme provider

import '../core/book-model/data.dart';
import '../core/style/app_styles.dart';

class BooksReadHorizontal extends ConsumerStatefulWidget { // Change to ConsumerStatefulWidget
  // final Booksdata book;
  final Map<String, dynamic> book;
  const BooksReadHorizontal({super.key, required this.book});

  @override
  ConsumerState<BooksReadHorizontal> createState() => _BooksReadHorizontalState();
}

class _BooksReadHorizontalState extends ConsumerState<BooksReadHorizontal> {
  bool _isLoading = false;
  String? _pdfPath;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  bool _isPdfReady = false;
  PDFViewController? _pdfViewController;
  double _fontSize = 16.0;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  int? _totalPages;
  int _percentageCompleted = 0;

  @override
  void initState() {
    super.initState();
    if (widget.book['pdfPath'] != null) {
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    setState(() => _isLoading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${widget.book['bookname'].replaceAll(' ', '_')}.pdf';

      final response = await Dio().get(
        widget.book['pdfPath']!,
        options: Options(responseType: ResponseType.bytes),
      );

      final file = await File(filePath).writeAsBytes(response.data);
      setState(() {
        _pdfPath = file.path;
        _isPdfReady = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;

    _backgroundColor = isDarkMode ? Colors.grey[700]! : AppStyles.bgColor;
    _textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['bookname'], style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),), // Apply theme
        backgroundColor: isDarkMode ? Colors.grey[900] : Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
      ),
      body: Stack(
        children: [
          if (_isPdfReady && _pdfPath != null)
            PDFView(
              key: ValueKey(_pdfPath),
              filePath: _pdfPath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              onRender: (pages) {
                setState(() {
                  _isPdfReady = true;
                  _totalPages = pages;
                  print('Total pages rendered: $_totalPages');
                });
              },
              onError: (error) => print('PDF Error: $error'),
              onPageError: (page, error) => print('Page $page Error: $error'),
              onViewCreated: (controller) {
                _pdfViewController = controller;
              },
              onPageChanged: (int? page, int? total) {
                print(
                    'Page changed to: $page, Total pages reported: $total, Current totalPages: $_totalPages');
                if (page != null && total != null && total > 0 && _totalPages != null && _totalPages! > 0) {
                  _currentPageNotifier.value = page;
                  _totalPages = total;
                  _percentageCompleted = ((page / _totalPages!) * 100).round();
                  print('Percentage completed: $_percentageCompleted (calculated in onPageChanged)');
                } else if (total != null && total > 0) {
                  _totalPages = total;
                }
                // Force rebuild to show updated percentage.
                setState(() {});
              },
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1, end: 0.0),
          if (_isLoading) Center(child: CircularProgressIndicator(color: isDarkMode ? Colors.white : null,))
          else if (widget.book['pdfPath'] != null && (!_isPdfReady || _pdfPath == null))
            Center(
              child: ElevatedButton(
                onPressed: _loadPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.grey[700] : null,
                  foregroundColor: isDarkMode ? Colors.white : null,
                ),
                child: const Text('Load PDF'),
              ),
            )
          else if (widget.book['pdfPath'] == null)
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: _backgroundColor,
                  child: Text(
                    widget.book['description'] ?? 'No content available',
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: _textColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          if (_isPdfReady && _pdfPath != null)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    return Text(
                      'Page ${currentPage + 1}/${_totalPages ?? '?'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600], // Apply theme
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;
    final totalPages = _totalPages ?? 0;
    final currentPage = _currentPageNotifier.value;
    final percentage = totalPages > 0
        ? ((currentPage / totalPages) * 100).round().clamp(0, 100)
        : 0;
    final percent = totalPages > 0 ? (percentage / 100) : 0.0;
    print('Current page: $currentPage, Total pages: $totalPages, Calculated percentage: $percentage');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Theme.of(context).appBarTheme.backgroundColor, // Apply theme
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: percent,
            backgroundColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!, // Apply theme
            progressColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage% completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.white : Colors.black87), // Apply theme
              ),
              if (_totalPages != null)
                ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    return Text(
                      'Page ${currentPage + 1}/${_totalPages}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.white : Colors.black87), // Apply theme
                    );
                  },
                ),
            ],
          ),
          if (_pdfPath != null && _pdfViewController != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon:  Icon(Icons.chevron_left, color: isDarkMode ? Colors.white : Colors.black87,), // Apply theme
                  onPressed: _currentPageNotifier.value > 0
                      ? () => _pdfViewController!.setPage(_currentPageNotifier.value - 1)
                      : null,
                ),
                IconButton(
                  icon:  Icon(Icons.chevron_right, color: isDarkMode ? Colors.white : Colors.black87,), // Apply theme
                  onPressed: _totalPages != null &&
                      _currentPageNotifier.value < _totalPages! - 1
                      ? () => _pdfViewController!.setPage(_currentPageNotifier.value + 1)
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

