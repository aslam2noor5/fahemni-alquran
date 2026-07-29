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
  List<dynamic> _allSurahs = [];
  List<dynamic> _filteredSurahs = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    setState(() { _loading = true; _error = null; });
    try {
      var res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          _allSurahs = data['data'];
          _filteredSurahs = _allSurahs;
          _loading = false;
        });
      } else {
        throw Exception('${res.statusCode}');
      }
    } catch (_) {
      setState(() { _error = 'فشل تحميل السور. تحقق من اتصالك بالإنترنت.'; _loading = false; });
    }
  }

  void _onSearch(String q) {
    setState(() {
      if (q.isEmpty) {
        _filteredSurahs = _allSurahs;
      } else {
        var query = q.toLowerCase();
        _filteredSurahs = _allSurahs.where((s) {
          return s['number'].toString() == query ||
              s['name'].toString().toLowerCase().contains(query) ||
              s['englishName'].toString().toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة بالاسم أو الرقم...',
              hintStyle: GoogleFonts.notoNaskhArabic(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: AppTheme.gold),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                '${_filteredSurahs.length} سورة',
                style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: AppTheme.gold),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredSurahs.isEmpty
              ? Center(child: Text('لا توجد نتائج', style: GoogleFonts.notoNaskhArabic(color: Colors.white70)))
              : ListView.builder(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
            itemCount: _filteredSurahs.length,
            itemBuilder: (ctx, i) {
              var s = _filteredSurahs[i];
              var typeAr = s['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _SurahViewScreen(
                          surahData: s,
                          allSurahs: _allSurahs,
                        ),
                      ),
                    );
                  },
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
                              Text('${s['englishName']} · $typeAr',
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
}

class _SurahViewScreen extends StatefulWidget {
  final dynamic surahData;
  final List<dynamic> allSurahs;
  const _SurahViewScreen({required this.surahData, required this.allSurahs});

  @override
  State<_SurahViewScreen> createState() => _SurahViewScreenState();
}

class _SurahViewScreenState extends State<_SurahViewScreen> {
  dynamic _surah;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    var num = widget.surahData['number'];
    try {
      var res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$num'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() { _surah = data['data']; _loading = false; });
      } else {
        throw Exception('${res.statusCode}');
      }
    } catch (_) {
      setState(() { _loading = false; });
    }
  }

  void _navigateSurah(int num) {
    var found = widget.allSurahs.firstWhere(
      (s) => s['number'] == num,
      orElse: () => widget.surahData,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _SurahViewScreen(surahData: found, allSurahs: widget.allSurahs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var typeAr = _surah != null
        ? (_surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية')
        : '';

    Map<String, List<dynamic>> pages = {};
    if (_surah != null) {
      for (var a in _surah['ayahs']) {
        var p = '${a['page']}';
        pages.putIfAbsent(p, () => []);
        pages[p]!.add(a);
      }
    }
    var pageKeys = pages.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    List<Widget> items = [];
    if (_surah != null) {
      for (var pKey in pageKeys) {
        items.add(_buildPageSep(pKey));
        for (var a in pages[pKey]!) {
          items.add(_buildVerseCard(a));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahData['name']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _surah == null
              ? Center(child: Text('فشل تحميل الآيات', style: GoogleFonts.notoNaskhArabic(color: Colors.white70)))
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.darkGreen]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(_surah['name'], style: GoogleFonts.notoNaskhArabic(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.gold)),
                          const SizedBox(height: 4),
                          Text('${_surah['englishName']} (${_surah['englishNameTranslation']})',
                            style: GoogleFonts.notoNaskhArabic(fontSize: 14, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text('$typeAr · ${_surah['numberOfAyahs']} آية · ${pageKeys.length} صفحة',
                            style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.white60)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        children: items,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (widget.surahData['number'] > 1)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _navigateSurah(widget.surahData['number'] - 1),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
                                child: Text('السورة السابقة', style: GoogleFonts.notoNaskhArabic()),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                          const SizedBox(width: 12),
                          if (widget.surahData['number'] < 114)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _navigateSurah(widget.surahData['number'] + 1),
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
                ),
    );
  }

  Widget _buildPageSep(String page) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        color: AppTheme.gold.withValues(alpha: 0.05),
      ),
      child: Text('صفحة $page', textAlign: TextAlign.center,
        style: GoogleFonts.notoNaskhArabic(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.gold)),
    );
  }

  Widget _buildVerseCard(dynamic a) {
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
            Text('${_surah!['name']} ${a['numberInSurah']}',
              style: GoogleFonts.notoNaskhArabic(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
