import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/models/audio_item.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';

class AudioTile extends StatelessWidget {
  final AudioItem item;
  final int index;
  final String surahName;
  final bool showFavoriteIcon;

  const AudioTile({
    super.key,
    required this.item,
    required this.index,
    required this.surahName,
    this.showFavoriteIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        final isCurrent = player.currentFileUrl == item.url;
        final isFav = player.isFavorite(item.url);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          elevation: isCurrent ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isCurrent ? AppTheme.gold : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (surahName.isNotEmpty) {
                player.setPlaylist(
                  [item],
                  surahName,
                  initialIndex: 0,
                );
              } else {
                player.togglePlayPause();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Index
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primaryGreen
                          : AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.white : AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? AppTheme.primaryGreen : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (surahName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            surahName,
                            style: GoogleFonts.notoNaskhArabic(
                              fontSize: 11,
                              color: AppTheme.gold.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showFavoriteIcon)
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFav ? AppTheme.gold : Colors.grey,
                      ),
                      onPressed: () => player.toggleFavorite(item.url),
                    ),
                  // Play button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? AppTheme.primaryGreen
                          : AppTheme.gold.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      isCurrent && player.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: isCurrent ? AppTheme.gold : AppTheme.primaryGreen,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
