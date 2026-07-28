import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/services/api_service.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';
import 'package:fahemni_alquran/widgets/audio_tile.dart';
import 'package:fahemni_alquran/widgets/player_bar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: Consumer2<ApiService, AudioPlayerService>(
        builder: (context, api, player, _) {
          // Collect all favorite files across surahs
          final favFiles = <MapEntry<String, dynamic>>[];
          for (final surah in api.surahs) {
            for (final file in surah.files) {
              if (player.isFavorite(file.url)) {
                favFiles.add(MapEntry(surah.name, file));
              }
            }
          }

          if (favFiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: AppTheme.gold.withValues(alpha: 0.5)),
                  const SizedBox(height: 20),
                  Text(
                    'لا توجد مفضلة',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'أضف ملفات إلى المفضلة للوصول السريع',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: AppTheme.gold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${favFiles.length} ملف مفضل',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 16,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, bottom: 100),
                  itemCount: favFiles.length,
                  itemBuilder: (context, index) {
                    final entry = favFiles[index];
                    final surah = api.surahs.firstWhere(
                      (s) => s.name == entry.key,
                    );
                    final fileIndex = surah.files.indexOf(entry.value);

                    return AudioTile(
                      item: entry.value,
                      index: fileIndex,
                      surahName: entry.key,
                      showFavoriteIcon: true,
                    );
                  },
                ),
              ),
              Consumer<AudioPlayerService>(
                builder: (context, playerService, _) {
                  if (playerService.currentItem != null) {
                    return const PlayerBar();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
