import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/models/audio_item.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';

class PlayerScreen extends StatefulWidget {
  final String surahName;
  final List<AudioItem> files;
  final int initialIndex;

  const PlayerScreen({
    super.key,
    required this.surahName,
    required this.files,
    this.initialIndex = 0,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 360).animate(
      CurvedAnimation(parent: _animController, curve: Curves.linear),
    );

    final player = Provider.of<AudioPlayerService>(context, listen: false);
    player.setPlaylist(widget.files, widget.surahName,
        initialIndex: widget.initialIndex);

    if (player.isPlaying) {
      _animController.repeat();
    }

    player.addListener(() {
      if (player.isPlaying && !_animController.isAnimating) {
        _animController.repeat();
      } else if (!player.isPlaying && _animController.isAnimating) {
        _animController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => _showPlaylist(context),
          ),
        ],
      ),
      body: Consumer<AudioPlayerService>(
        builder: (context, player, _) {
          if (player.currentItem == null) {
            return Center(
              child: Text(
                'لا يوجد ملف قيد التشغيل',
                style: GoogleFonts.notoNaskhArabic(fontSize: 18),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Album art - logo with rotation
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 3.14159 / 180,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.gold,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.gold.withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // File name
                  Text(
                    player.currentFileName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.surahName,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 14,
                      color: AppTheme.gold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Progress bar
                  Row(
                    children: [
                      Text(
                        _formatDuration(player.position),
                        style: GoogleFonts.notoNaskhArabic(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20),
                          ),
                          child: Slider(
                            value: player.duration.inSeconds > 0
                                ? player.position.inSeconds
                                        .toDouble()
                                        .clamp(0, player.duration.inSeconds.toDouble())
                                : 0,
                            min: 0,
                            max: player.duration.inSeconds > 0
                                ? player.duration.inSeconds.toDouble()
                                : 1,
                            onChanged: (value) {
                              player.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                      ),
                      Text(
                        player.duration.inSeconds > 0
                            ? _formatDuration(player.duration)
                            : '00:00',
                        style: GoogleFonts.notoNaskhArabic(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: player.isShuffled
                              ? AppTheme.gold
                              : Colors.grey,
                        ),
                        iconSize: 28,
                        onPressed: () => player.toggleShuffle(),
                      ),
                      const SizedBox(width: 10),
                      // Previous
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: AppTheme.primaryGreen),
                          iconSize: 36,
                          onPressed: () => player.previous(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Play/Pause
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x664CAF50),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            player.isLoading
                                ? Icons.hourglass_top
                                : player.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                            color: AppTheme.gold,
                          ),
                          iconSize: 40,
                          onPressed: () => player.togglePlayPause(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Next
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: AppTheme.primaryGreen),
                          iconSize: 36,
                          onPressed: () => player.next(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Repeat
                      IconButton(
                        icon: Icon(
                          player.isRepeating
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: player.isRepeating
                              ? AppTheme.gold
                              : Colors.grey,
                        ),
                        iconSize: 28,
                        onPressed: () => player.toggleRepeat(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Favorite button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (player.currentFileUrl.isNotEmpty) {
                          player.toggleFavorite(player.currentFileUrl);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            player.currentFileUrl.isNotEmpty &&
                                    player.isFavorite(player.currentFileUrl)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppTheme.gold,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            player.currentFileUrl.isNotEmpty &&
                                    player.isFavorite(player.currentFileUrl)
                                ? 'تمت الإضافة للمفضلة'
                                : 'أضف إلى المفضلة',
                            style: GoogleFonts.notoNaskhArabic(
                              fontSize: 14,
                              color: AppTheme.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPlaylist(BuildContext context) {
    final player = Provider.of<AudioPlayerService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'قائمة التشغيل',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: AppTheme.gold.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: widget.files.length,
                  itemBuilder: (ctx, index) {
                    final isCurrent = index == player.currentIndex;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
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
                              color: isCurrent ? Colors.white : AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        widget.files[index].name,
                        style: GoogleFonts.notoNaskhArabic(
                          fontSize: 14,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? AppTheme.primaryGreen : null,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.music_note,
                              color: AppTheme.gold)
                          : null,
                      onTap: () {
                        player.setPlaylist(
                          widget.files,
                          widget.surahName,
                          initialIndex: index,
                        );
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget needed for rotation
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
