import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';
import 'package:fahemni_alquran/screens/player_screen.dart';
import 'package:fahemni_alquran/models/audio_item.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        return Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Play button (center)
                GestureDetector(
                  onTap: () => player.togglePlayPause(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold,
                    ),
                    child: Icon(
                      player.isLoading
                          ? Icons.hourglass_top
                          : player.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                      color: AppTheme.primaryGreen,
                      size: 28,
                    ),
                  ),
                ),
                // Info + Progress (right)
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.player,
                        arguments: {
                          'surahName': player.currentSurahName,
                          'files': player.playlist,
                          'initialIndex': player.currentIndex,
                        },
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              player.currentFileName,
                              style: GoogleFonts.notoNaskhArabic(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              player.currentSurahName,
                              style: GoogleFonts.notoNaskhArabic(
                                fontSize: 11,
                                color: AppTheme.goldLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: StreamBuilder<Duration>(
                            stream: player.player.positionStream,
                            builder: (context, snapshot) {
                              final pos = snapshot.data ?? Duration.zero;
                              final dur = player.duration;
                              final progress = dur.inSeconds > 0
                                  ? (pos.inSeconds / dur.inSeconds)
                                  : 0.0;
                              return LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.gold),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Next button (left)
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () => player.next(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
