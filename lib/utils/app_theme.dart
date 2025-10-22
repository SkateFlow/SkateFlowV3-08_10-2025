import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores do Design System da Web
  static const Color primaryColor = Color(0xFF043C70);
  static const Color secondaryColor = Color(0xFF3888D2);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF000000);
  static const Color lightGray = Color(0xFF888888);
  
  // Estilos de Card
  static BoxDecoration cardDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // Estilos de Botão
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    elevation: 0,
  );
  
  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
  );
  
  // Gradiente de fundo
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, secondaryColor],
  );
  
  // Estilos de texto
  static TextStyle get headingStyle => GoogleFonts.lexend(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: textColor,
  );
  
  static TextStyle get subheadingStyle => GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: textColor,
  );
  
  static TextStyle get bodyStyle => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textColor,
  );
  
  static TextStyle get captionStyle => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: lightGray,
  );
}