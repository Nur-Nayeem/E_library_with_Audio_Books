import 'package:audiobook_e_library/core/style/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../core/theme/theme_provider.dart'; // Import your theme provider

class BooksListen extends ConsumerStatefulWidget { // Change to ConsumerStatefulWidget
  final Map<String, dynamic> book;

  const BooksListen({super.key, required this.book});

  @override
  ConsumerState<BooksListen> createState() => _BooksListenState();
}

class _BooksListenState extends ConsumerState<BooksListen> {
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
    try {
      await _audioPlayer.setSource(
          UrlSource(widget.book['audioPaths']![index]));
      await _audioPlayer.resume();
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) { //check mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load audio')),
        );
      }
    }
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
    final h = d.inHours.remainder(60).toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h == null ? "$m:$s" : "$h:$m:$s";
  }

  void _playPrevious() {
    if (currentIndex > 0) {
      _loadAudio(index: currentIndex - 1);
    }
  }

  void _playNext() {
    if (currentIndex < (widget.book['audioPaths']?.length ?? 0) - 1) {
      _loadAudio(index: currentIndex + 1);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioPaths = widget.book['audioPaths'] ?? [];
    final themeMode = ref.watch(themeProvider); // Get the current theme
    final isDarkMode = themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : AppStyles.bgColor, // Apply theme
      appBar: AppBar(
        title: Text(widget.book['bookname'],
            style:  TextStyle(color: isDarkMode ? Colors.white : const Color(0xff333333))), // Apply theme
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : const Color(0xff333333)), // Apply theme
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Book cover image with a subtle shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.book['imagePath'],
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.book['bookname'],
            textAlign: TextAlign.center,
            style:  TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xff2e2e2e), // Apply theme
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "By ${widget.book['authorName']}",
            style:  TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : const Color(0xff555555)), // Apply theme
          ),
          const SizedBox(height: 25),

          // Slider with custom styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xffa83b2d), // Burnt orange
                inactiveTrackColor: isDarkMode ? Colors.grey[850] : const Color(0xffdcd0c0), // Light beige
                thumbColor: const Color(0xffa83b2d),
                overlayColor: const Color(0xffa83b2d).withOpacity(0.3),
                thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 14.0),
              ),
              child: Slider(
                value: currentPosition.inSeconds.toDouble(),
                max: totalDuration.inSeconds.toDouble(),
                onChanged: (value) =>
                    _seekTo(Duration(seconds: value.toInt())),
              ),
            ),
          ),

          // Time indicators with a bit more spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(currentPosition),
                    style:  TextStyle(color: isDarkMode ? Colors.grey[300] : const Color(0xff666666))), // Apply theme
                Text(_formatTime(totalDuration),
                    style:  TextStyle(color: isDarkMode ? Colors.grey[300] : const Color(0xff666666))), // Apply theme
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Beautifully designed playback controls
          if (isLoading)
            CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffa83b2d)),
              color: isDarkMode ? Colors.grey[850] : null,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _playPrevious,
                  icon:  Icon(Icons.skip_previous_rounded,
                      size: 40, color: isDarkMode ? Colors.white : const Color(0xff444444)), // Apply theme
                ),
                IconButton(
                  onPressed: _seekBackward10s,
                  icon:  Icon(Icons.replay_10_rounded,
                      size: 36, color: isDarkMode ? Colors.white : const Color(0xff555555)), // Apply theme
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffa83b2d),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _seekForward10s,
                  icon:  Icon(Icons.forward_10_rounded,
                      size: 36, color: isDarkMode ? Colors.white : const Color(0xff555555)), // Apply theme
                ),
                IconButton(
                  onPressed: _playNext,
                  icon:  Icon(Icons.skip_next_rounded,
                      size: 40, color: isDarkMode ? Colors.white : const Color(0xff444444)), // Apply theme
                ),
              ],
            ),
          const SizedBox(height: 25),

          // Styled chapter list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: audioPaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _loadAudio(index: index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? const Color(0xffe0f2f7) // Light cyan when selected
                          : isDarkMode ? Colors.grey[900]! : Colors.white, // Apply theme
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: currentIndex == index
                          ? Border.all(color: const Color(0xff26a69a), width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentIndex == index
                              ? Icons.play_circle_fill_rounded
                              : Icons.headphones_rounded,
                          color: currentIndex == index
                              ? const Color(0xff26a69a)
                              : isDarkMode ? Colors.white : Colors.grey.shade600, // Apply theme
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Chapter ${index + 1}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: currentIndex == index
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isDarkMode ? Colors.white : const Color(0xff333333), // Apply theme
                            ),
                          ),
                        ),
                      ],
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

