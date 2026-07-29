import 'package:flutter/material.dart';
import 'package:fahemni_alquran/screens/splash_screen.dart';
import 'package:fahemni_alquran/screens/home_screen.dart';
import 'package:fahemni_alquran/screens/surah_detail_screen.dart';
import 'package:fahemni_alquran/screens/player_screen.dart';
import 'package:fahemni_alquran/screens/favorites_screen.dart';
import 'package:fahemni_alquran/screens/settings_screen.dart';
import 'package:fahemni_alquran/screens/quran_screen.dart';
import 'package:fahemni_alquran/models/surah.dart';
import 'package:fahemni_alquran/models/audio_item.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String surahDetail = '/surah-detail';
  static const String player = '/player';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String quran = '/quran';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case home:
        return _buildRoute(const HomeScreen(), settings);

      case surahDetail:
        final surah = settings.arguments as Surah;
        return _buildRoute(SurahDetailScreen(surah: surah), settings);

      case player:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          PlayerScreen(
            surahName: args['surahName'] as String,
            files: args['files'] as List<AudioItem>,
            initialIndex: args['initialIndex'] as int? ?? 0,
          ),
          settings,
        );

      case favorites:
        return _buildRoute(const FavoritesScreen(), settings);

      case settings:
        return _buildRoute(const SettingsScreen(), settings);

      case quran:
        return _buildRoute(const QuranScreen(), settings);

      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
