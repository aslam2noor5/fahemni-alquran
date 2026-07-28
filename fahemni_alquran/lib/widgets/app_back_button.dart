import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      label: Text(
        'رجوع',
        style: GoogleFonts.notoNaskhArabic(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
      ),
    );
  }
}
