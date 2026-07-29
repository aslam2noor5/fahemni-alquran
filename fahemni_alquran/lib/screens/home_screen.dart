import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/services/api_service.dart';
import 'package:fahemni_alquran/services/audio_player_service.dart';
import 'package:fahemni_alquran/widgets/surah_card.dart';
import 'package:fahemni_alquran/widgets/player_bar.dart';
import 'package:fahemni_alquran/config/routes.dart';
import 'package:fahemni_alquran/models/audio_item.dart';
import 'package:fahemni_alquran/screens/favorites_screen.dart';
import 'package:fahemni_alquran/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Decorative header
          _buildHeader(context),
          // Content
          Expanded(
            child: Consumer<ApiService>(
              builder: (context, apiService, _) {
                if (apiService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (apiService.error != null &&
                    apiService.surahs.isEmpty) {
                  return _buildErrorView(apiService);
                }

                final surahs = _searchQuery.isEmpty
                    ? apiService.surahs
                    : apiService.search(_searchQuery);

                if (surahs.isEmpty) {
                  return _buildEmptyView();
                }

                final hasIntro = apiService.introFiles.isNotEmpty &&
                    (_searchQuery.isEmpty ||
                        apiService.introFiles.any((f) =>
                            f.name.toLowerCase().contains(_searchQuery.toLowerCase())));

                return RefreshIndicator(
                  onRefresh: () => apiService.loadData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 12, bottom: 100),
                    itemCount: surahs.length + (hasIntro ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasIntro && index == 0) {
                        return _buildIntroCard(context, apiService.introFiles.first);
                      }
                      final surahIndex = hasIntro ? index - 1 : index;
                      return SurahCard(
                        surah: surahs[surahIndex],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.surahDetail,
                            arguments: surahs[surahIndex],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Mini Player
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.quran);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.favorites);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.settings);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'السور',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'المصحف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context, AudioItem introFile) {
    final player = context.read<AudioPlayerService>();
    final isPlaying = player.currentItem?.url == introFile.url && player.isPlaying;
    final isCurrent = player.currentItem?.url == introFile.url;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.gold, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.player,
            arguments: {
              'surahName': 'مقدمة السلسلة',
              'files': [introFile],
              'initialIndex': 0,
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.gold.withValues(alpha: 0.08),
                AppTheme.primaryGreen.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, Color(0xFFB8960C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.star, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      introFile.name,
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCurrent
                          ? (isPlaying ? 'جارٍ التشغيل' : 'متوقف')
                          : 'اضغط للتشغيل',
                      style: GoogleFonts.notoNaskhArabic(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCurrent && isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppTheme.gold,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      textAlign: TextAlign.right,
      style: GoogleFonts.notoNaskhArabic(color: Colors.white, fontSize: 16),
      decoration: const InputDecoration(
        hintText: 'ابحث عن سورة...',
        hintStyle: TextStyle(color: Colors.white60),
        border: InputBorder.none,
        fillColor: Colors.transparent,
        filled: true,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book, color: AppTheme.gold, size: 28),
          const SizedBox(width: 12),
          Text(
            'اختر سورة للاستماع',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 14,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (!_isSearching)
            Consumer<ApiService>(
              builder: (context, api, _) {
                return Text(
                  '114 سورة',
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 12,
                    color: AppTheme.gold,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ApiService api) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off,
                size: 80, color: AppTheme.gold),
            const SizedBox(height: 20),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => api.loadData(),
              icon: const Icon(Icons.refresh),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.notoNaskhArabic(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: AppTheme.gold),
          const SizedBox(height: 20),
          Text(
            'لا توجد نتائج',
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
