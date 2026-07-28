import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/models/surah.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';
import 'package:fahemni_alquran/widgets/audio_tile.dart';
import 'package:fahemni_alquran/widgets/player_bar.dart';
import 'package:fahemni_alquran/widgets/app_back_button.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: _AudioSearchDelegate(widget.surah.files),
                      );
                    },
                  ),
                ],
              ),
            ),
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
