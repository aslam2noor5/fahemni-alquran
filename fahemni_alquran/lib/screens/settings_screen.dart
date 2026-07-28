import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/main.dart';
import 'package:fahemni_alquran/services/storage_service.dart';
import 'package:fahemni_alquran/widgets/app_back_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppBackButton(),
            const SizedBox(height: 8),
            // Appearance section
            _buildSectionHeader('المظهر', Icons.palette),
            Card(
              child: SwitchListTile(
                title: Text(
                  'المظهر الداكن',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                ),
                subtitle: Text(
                  'التبديل إلى المظهر الفاتح',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                ),
                secondary: Icon(
                  themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.gold,
                ),
                value: themeProvider.isDark,
                onChanged: (value) {
                  themeProvider.setDark(value);
                  context.read<StorageService>().saveString(
                    AppConstants.cacheKeyThemeMode,
                    value ? 'dark' : 'light',
                  );
                },
                activeColor: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),

            // About section
            _buildSectionHeader('عن التطبيق', Icons.info_outline),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.menu_book, color: AppTheme.gold),
                    title: Text(
                      'فهمني القرآن',
                      style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                    ),
                    subtitle: Text(
                      'استمع إلى شرح القرآن الكريم',
                      style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Divider(color: AppTheme.gold.withValues(alpha: 0.2)),
                  ListTile(
                    leading: Icon(Icons.code, color: AppTheme.gold),
                    title: Text(
                      'الإصدار',
                      style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                    ),
                    trailing: Text(
                      AppConstants.version,
                      style: GoogleFonts.notoNaskhArabic(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Support section
            _buildSectionHeader('الدعم', Icons.support),
            Card(
              child: ListTile(
                leading: Icon(Icons.email, color: AppTheme.gold),
                title: Text(
                  'تواصل معنا',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 16),
                ),
                subtitle: Text(
                  'support@fahemni-alquran.app',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                'جميع الحقوق محفوظة © 2026',
                style: GoogleFonts.notoNaskhArabic(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
