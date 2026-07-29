import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:fahemni_alquran/config/theme.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<dynamic> _surahs = [];
  bool _loading = true;
  bool _loadingVerses = false;
  String? _error;
  Map<int, dynamic> _verseCache = {};
  int? _currentSurah;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    setState(() { _loading = true; _error = null; });
    try {
      var res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() { _surahs = data['data']; _loading = false; });
      } else {
        throw Exception('${res.statusCode}');
      }
    } catch (_) {
      setState(() { _error = 'فشل تحميل السور. تحقق من اتصالك بالإنترنت.'; _loading = false; });
    }
  }

  Future<void> _openSurah(int num) async {
    setState(() { _currentSurah = num; _loadingVerses = true; });
    if (_verseCache.containsKey(num)) {
      setState(() { _loadingVerses = false; });
      return;
    }
    try {
      var res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$num'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        _verseCache[num] = data['data'];
      }
    } catch (_) {}
    setState(() { _loadingVerses = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSurah != null) {
      return _buildSurahView();
    }
    return _buildSurahList();
  }

  Widget _buildSurahList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppTheme.gold),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.notoNaskhArabic(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSurahs,
              icon: const Icon(Icons.refresh),
              label: Text('إعادة المحاولة', style: GoogleFonts.notoNaskhArabic()),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.menu_book, color: AppTheme.gold, size: 28),
              const SizedBox(width: 12),
              Text(
                'المصحف الشريف',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 14, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${_surahs.length} سورة',
                style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: AppTheme.gold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
            itemCount: _surahs.length,
            itemBuilder: (ctx, i) {
              var s = _surahs[i];
              var typeAr = s['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openSurah(s['number']),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.darkGreen]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(child: Text('${s['number']}', style: GoogleFonts.notoNaskhArabic(color: AppTheme.gold, fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'], style: GoogleFonts.notoNaskhArabic(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                              const SizedBox(height: 4),
                              Text('${s['englishName']} · $typeAr · ${s['numberOfAyahs']} آية',
                                style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left, color: AppTheme.gold),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurahView() {
    var surah = _verseCache[_currentSurah];
    var typeAr = surah != null ? (surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية') : '';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => setState(() { _currentSurah = null; }),
              ),
            ],
          ),
        ),
        if (surah != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.darkGreen]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(surah['name'], style: GoogleFonts.notoNaskhArabic(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.gold)),
                const SizedBox(height: 4),
                Text('${surah['englishName']} (${surah['englishNameTranslation']})',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text('$typeAr · ${surah['numberOfAyahs']} آية',
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
        if (_loadingVerses)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (surah != null)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: surah['ayahs'].length,
              itemBuilder: (ctx, i) {
                var a = surah['ayahs'][i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            Container(
                              width: 28, height: 28,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold),
                              child: Center(child: Text('${a['numberInSurah']}', style: const TextStyle(fontSize: 11, color: Colors.white))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(a['text'], textAlign: TextAlign.center,
                          style: GoogleFonts.notoNaskhArabic(fontSize: 22, height: 2.0)),
                        const SizedBox(height: 4),
                        Text('${surah['name']} ${a['numberInSurah']}',
                          style: GoogleFonts.notoNaskhArabic(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (surah != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (_currentSurah! > 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openSurah(_currentSurah! - 1),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
                      child: Text('السورة السابقة', style: GoogleFonts.notoNaskhArabic()),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                const SizedBox(width: 12),
                if (_currentSurah! < 114)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openSurah(_currentSurah! + 1),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
                      child: Text('السورة التالية', style: GoogleFonts.notoNaskhArabic()),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}
