// core/style/app_double_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDoubleText extends StatelessWidget {
  final String bigText;
  final String smallText;
  final VoidCallback? func; // Make func nullable

  const AppDoubleText({
    super.key,
    required this.bigText,
    required this.smallText,
    this.func, // Initialize func in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          bigText,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: func, // Call the provided function when tapped
          child: Text(
            smallText,
            style: GoogleFonts.poppins(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}