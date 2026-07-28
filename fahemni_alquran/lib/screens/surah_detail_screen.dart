import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/models/surah.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';
import 'package:fahemni_alquran/widgets/audio_tile.dart';
import 'package:fahemni_alquran/widgets/player_bar.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final files = _searchQuery.isEmpty
        ? widget.surah.files
        : widget.surah.files
            .where((f) =>
                f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: ctx,
                  delegate: _AudioSearchDelegate(widget.surah.files),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Surah header
          _buildSurahHeader(),
          // Files list
          Expanded(
            child: files.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد ملفات مطابقة',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 8, bottom: 100),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return AudioTile(
                        item: files[index],
                        index: index,
                        surahName: widget.surah.name,
                      );
                    },
                  ),
          ),
          // Mini player
          Consumer<AudioPlayerService>(
            builder: (context, playerService, _) {
              if (playerService.currentItem != null) {
                return const PlayerBar();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.menu_book, size: 40, color: AppTheme.gold),
          const SizedBox(height: 10),
          Text(
            widget.surah.name,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.surah.files.length} ملف صوتي',
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 14,
                color: AppTheme.goldLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioSearchDelegate extends SearchDelegate<String?> {
  final List<dynamic> files;

  _AudioSearchDelegate(this.files);

  @override
  String get searchFieldLabel => 'ابحث في الملفات...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final results = files
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج',
          style: GoogleFonts.notoNaskhArabic(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return AudioTile(
          item: item,
          index: files.indexOf(item),
          surahName: '',
        );
      },
    );
  }
}
