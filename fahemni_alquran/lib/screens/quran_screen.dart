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
              Text('المصحف الشريف', style: GoogleFonts.notoNaskhArabic(fontSize: 14, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('${_filteredSurahs.length} سورة', style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: AppTheme.gold)),
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
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => _SurahViewScreen(surahData: s, allSurahs: _allSurahs),
                    ));
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
                              Text('${s['englishName']} · $typeAr', style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.grey)),
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
  int _currentPageIdx = 0;
  List<String> _pageKeys = [];

  // In-surah search
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic>? _searchResults;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVerses() async {
    var num = widget.surahData['number'];
    try {
      var res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$num'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() { _surah = data['data']; _loading = false; });
        _buildPages();
      } else {
        throw Exception('${res.statusCode}');
      }
    } catch (_) {
      setState(() { _loading = false; });
    }
  }

  void _buildPages() {
    if (_surah == null) return;
    Map<String, List<dynamic>> pages = {};
    for (var a in _surah['ayahs']) {
      var p = '${a['page']}';
      pages.putIfAbsent(p, () => []);
      pages[p]!.add(a);
    }
    _pageKeys = pages.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    _currentPageIdx = 0;
  }

  List<dynamic> get _currentAyahs {
    if (_surah == null || _pageKeys.isEmpty) return [];
    var key = _pageKeys[_currentPageIdx];
    return _surah['ayahs'].where((a) => '${a['page']}' == key).toList();
  }

  void _onSearch(String q) {
    setState(() {
      var query = q.trim();
      if (query.isEmpty) {
        _searchResults = null;
        return;
      }
      var ayahNum = int.tryParse(query);
      _searchResults = _surah['ayahs'].where((a) {
        if (ayahNum != null && a['numberInSurah'] == ayahNum) return true;
        return a['text'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _navigateSurah(int num) {
    var found = widget.allSurahs.firstWhere((s) => s['number'] == num, orElse: () => widget.surahData);
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => _SurahViewScreen(surahData: found, allSurahs: widget.allSurahs),
    ));
  }

  void _jumpToAyah(int ayahNum) {
    var aya = _surah['ayahs'].firstWhere(
      (a) => a['numberInSurah'] == ayahNum,
      orElse: () => null,
    );
    if (aya == null) return;
    var pageKey = '${aya['page']}';
    var idx = _pageKeys.indexOf(pageKey);
    if (idx >= 0) {
      setState(() {
        _currentPageIdx = idx;
        _searchCtrl.clear();
        _searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var typeAr = _surah != null
        ? (_surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية')
        : '';

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
                    // In-surah search
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearch,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن آية (رقم أو نص)...',
                          hintStyle: GoogleFonts.notoNaskhArabic(fontSize: 13, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.gold, size: 20),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        ),
                      ),
                    ),
                    // Header
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.darkGreen]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(_surah['name'], style: GoogleFonts.notoNaskhArabic(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.gold)),
                          const SizedBox(height: 2),
                          Text('${_surah['englishName']} (${_surah['englishNameTranslation']})', style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text('$typeAr · ${_surah['numberOfAyahs']} آية · ${_pageKeys.length} صفحة', style: GoogleFonts.notoNaskhArabic(fontSize: 11, color: Colors.white60)),
                        ],
                      ),
                    ),
                    // Content: search results or page view
                    Expanded(
                      child: _searchResults != null
                          ? _buildSearchResults()
                          : _buildPageView(),
                    ),
                    // Page navigation / Surah navigation
                    if (_searchResults == null) _buildNavigation(),
                  ],
                ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults!.isEmpty) {
      return Center(child: Text('لا توجد نتائج', style: GoogleFonts.notoNaskhArabic(color: Colors.white70)));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text('${_searchResults!.length} نتيجة', style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: AppTheme.gold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _searchResults!.length,
            itemBuilder: (ctx, i) {
              var a = _searchResults![i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: InkWell(
                  onTap: () => _jumpToAyah(a['numberInSurah']),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            Container(
                              width: 26, height: 26,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold),
                              child: Center(child: Text('${a['numberInSurah']}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                            ),
                          ],
                        ),
                        Text(a['text'], textAlign: TextAlign.center, style: GoogleFonts.notoNaskhArabic(fontSize: 18, height: 1.8)),
                        Text('صفحة ${a['page']} · ${_surah!['name']} ${a['numberInSurah']}',
                          style: GoogleFonts.notoNaskhArabic(fontSize: 10, color: Colors.grey)),
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

  Widget _buildPageView() {
    var ayahs = _currentAyahs;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.darkGreen]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('صفحة ${_pageKeys[_currentPageIdx]}', textAlign: TextAlign.center,
            style: GoogleFonts.notoNaskhArabic(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.gold)),
        ),
        ...ayahs.map((a) => Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      width: 26, height: 26,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold),
                      child: Center(child: Text('${a['numberInSurah']}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                    ),
                  ],
                ),
                Text(a['text'], textAlign: TextAlign.center, style: GoogleFonts.notoNaskhArabic(fontSize: 20, height: 2.0)),
                Text('${_surah!['name']} ${a['numberInSurah']}', style: GoogleFonts.notoNaskhArabic(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        children: [
          // Page nav
          Row(
            children: [
              if (_currentPageIdx > 0)
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => setState(() { _currentPageIdx--; }),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, padding: EdgeInsets.zero),
                      child: Text('الصفحة السابقة', style: GoogleFonts.notoNaskhArabic(fontSize: 12)),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 8),
              SizedBox(
                width: 80, height: 36,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '${_currentPageIdx + 1}',
                    hintStyle: GoogleFonts.notoNaskhArabic(fontSize: 12, color: AppTheme.gold),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3))),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  ),
                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, color: AppTheme.gold),
                  onSubmitted: (v) {
                    var val = int.tryParse(v);
                    if (val != null && val >= 1 && val <= _pageKeys.length) {
                      setState(() { _currentPageIdx = val - 1; });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (_currentPageIdx < _pageKeys.length - 1)
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => setState(() { _currentPageIdx++; }),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, padding: EdgeInsets.zero),
                      child: Text('الصفحة التالية', style: GoogleFonts.notoNaskhArabic(fontSize: 12)),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 4),
          // Surah nav
          Row(
            children: [
              if (widget.surahData['number'] > 1)
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _navigateSurah(widget.surahData['number'] - 1),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, padding: EdgeInsets.zero),
                      child: Text('السورة السابقة', style: GoogleFonts.notoNaskhArabic(fontSize: 12)),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 8),
              SizedBox(
                width: 80, height: 36,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'رقم الآية',
                    hintStyle: GoogleFonts.notoNaskhArabic(fontSize: 11, color: Colors.grey),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3))),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  ),
                  style: GoogleFonts.notoNaskhArabic(fontSize: 11),
                  onSubmitted: (v) {
                    var val = int.tryParse(v);
                    if (val != null && val >= 1 && val <= (_surah?['numberOfAyahs'] ?? 0)) {
                      _jumpToAyah(val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (widget.surahData['number'] < 114)
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _navigateSurah(widget.surahData['number'] + 1),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, padding: EdgeInsets.zero),
                      child: Text('السورة التالية', style: GoogleFonts.notoNaskhArabic(fontSize: 12)),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}
