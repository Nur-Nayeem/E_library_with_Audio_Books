import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class AppDoubleText extends ConsumerWidget {
  final String bigText;
  final String smallText;
  final VoidCallback? func;

  const AppDoubleText({
    super.key,
    required this.bigText,
    required this.smallText,
    this.func,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          bigText,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: func,
          child: Text(
            smallText,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.grey[400] : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

