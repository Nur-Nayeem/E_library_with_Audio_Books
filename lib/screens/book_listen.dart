import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/book-model/data.dart'; // import your Booksdata model

class BooksListen extends StatefulWidget {
  // final Booksdata book;
  final Map<String, dynamic> book;
  const BooksListen({super.key, required this.book});

  @override
  State<BooksListen> createState() => _BooksListenState();
}

class _BooksListenState extends State<BooksListen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int currentIndex = 0;
  bool isPlaying = false;
  bool isLoading = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadAudio(index: 0);
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => currentPosition = position);
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => totalDuration = duration);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    });
  }

  Future<void> _loadAudio({required int index}) async {
    setState(() {
      isLoading = true;
      currentIndex = index;
    });

    await _audioPlayer.stop();
    await _audioPlayer.setSource(UrlSource(widget.book['audioPaths']![index]));
    await _audioPlayer.resume();

    setState(() {
      isPlaying = true;
      isLoading = false;
    });
  }

  void _seekTo(Duration position) => _audioPlayer.seek(position);

  void _seekForward10s() {
    final newPos = currentPosition + const Duration(seconds: 10);
    if (newPos < totalDuration) _seekTo(newPos);
  }

  void _seekBackward10s() {
    final newPos = currentPosition - const Duration(seconds: 10);
    _seekTo(newPos > Duration.zero ? newPos : Duration.zero);
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => isPlaying = !isPlaying);
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioPaths = widget.book['audioPaths'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xfffff8ee),
      appBar: AppBar(
        title: Text(widget.book['bookname'], style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Book cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.book['imagePath'],
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.book['bookname'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "By ${widget.book['authorName']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Slider for audio position
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Slider(
              value: currentPosition.inSeconds.toDouble(),
              max: totalDuration.inSeconds.toDouble(),
              onChanged: (value) => _seekTo(Duration(seconds: value.toInt())),
              activeColor: const Color(0xffc44536),
            ),
          ),

          // Time indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(currentPosition)),
                Text(_formatTime(totalDuration)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Play/pause controls
          if (isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _seekBackward10s,
                  icon: const Icon(Icons.replay_10),
                  iconSize: 36,
                ),
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 50,
                ),
                IconButton(
                  onPressed: _seekForward10s,
                  icon: const Icon(Icons.forward_10),
                  iconSize: 36,
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Chapter list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: audioPaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _loadAudio(index: index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.teal.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Chapter ${index + 1}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
