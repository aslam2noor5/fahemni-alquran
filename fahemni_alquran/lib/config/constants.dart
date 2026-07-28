class AppConstants {
  static const String appName = 'فهمني القرآن';
  static const String appNameEn = 'Fahemni AlQuran';
  static const String version = '1.0.0';

  // API
  static const String defaultDataUrl =
      'https://pub-xxxxx.r2.dev/data.json';
  static const String cacheKeyData = 'cached_data';
  static const String cacheKeyFavorites = 'favorites';
  static const String cacheKeyLastPlayed = 'last_played';
  static const String cacheKeyThemeMode = 'theme_mode';
  static const String cacheKeyLastSurah = 'last_surah_index';
  static const String cacheKeyLastFile = 'last_file_index';
  static const String cacheKeyLastPosition = 'last_position';

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);
}
