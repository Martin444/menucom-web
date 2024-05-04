import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickme_up_web/utils/pu_colors.dart';

class PuTextStyle {
  static TextStyle title1 = GoogleFonts.openSans(
    color: PUColors.textColor1,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  static TextStyle titleSecundary = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static TextStyle title3 = GoogleFonts.openSans(
    color: PUColors.textColor1,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle title2 = GoogleFonts.openSans(
    color: PUColors.textColor1,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle title3disable = GoogleFonts.openSans(
    color: const Color.fromARGB(255, 213, 213, 213),
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle title4 = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static TextStyle title5 = GoogleFonts.openSans(
    color: PUColors.textColor1,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle title6 = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle description1 = GoogleFonts.openSans(
    color: PUColors.textColor1,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  static TextStyle description2 = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w200,
    height: 1.0,
  );

  static TextStyle primaryButtonStyle = GoogleFonts.openSans(
    color: PUColors.textColor2,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.8,
  );

  static TextStyle secundaryButtonStyle = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle textInput1 = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
