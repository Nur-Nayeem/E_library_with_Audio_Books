import 'package:flutter/material.dart';

Color primary = const Color(0xFF687daf);

class AppStyles {
  static Color primaryColor = primary;
  static Color textColor = Color(0xFF3b3b3b);
  static Color bgColor = const Color(0xff43b8a1);
  static Color userBg = const Color(0xFF5C9A9A);
  static Color userIcon = const Color(0xFF1E5E71);
  static Color kakiColor = const Color(0xFFd2bdb6);
  static Color appTicketTabColor = const Color(0xFFF4F6FD);
  static Color planeColor = const Color(0xFFBFC2DF);
  static Color findTicketButtonColor = const Color(0xD91130CE);

  static TextStyle textStyle =
      TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500);

  static TextStyle headLineStyle1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: textColor,
  );
  static TextStyle headLineStyle2 = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.bold,
    color: textColor,
  );
  static TextStyle headLineStyle3 = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );
  static TextStyle headLineStyle4 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
