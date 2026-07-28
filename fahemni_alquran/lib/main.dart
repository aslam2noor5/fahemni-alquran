import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/routes.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/services/api_service.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';
import 'package:fahemni_alquran/services/storage_service.dart';
import 'package:fahemni_alquran/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final themeProvider = ThemeProvider();
  final themeMode = storageService.getString(AppConstants.cacheKeyThemeMode);
  if (themeMode == 'light') {
    themeProvider.setDark(false);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
        ChangeNotifierProvider.value(value: storageService),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const FahemniAlQuranApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDark(bool value) {
    _isDark = value;
    notifyListeners();
  }
}

class FahemniAlQuranApp extends StatelessWidget {
  const FahemniAlQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const SplashScreen(),
    );
  }
}
