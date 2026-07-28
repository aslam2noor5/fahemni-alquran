import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/models/surah.dart';

class ApiService extends ChangeNotifier {
  List<Surah> _surahs = [];
  bool _isLoading = false;
  String? _error;
  String _dataSource = '';

  List<Surah> get surahs => _surahs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get dataSource => _dataSource;

  Future<void> loadData({String? customUrl}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = customUrl ?? AppConstants.defaultDataUrl;

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> surahsJson = jsonData['surahs'];
        _surahs = surahsJson
            .map((e) => Surah.fromJson(e as Map<String, dynamic>))
            .toList();
        _dataSource = 'online';

        // Cache the data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.cacheKeyData, response.body);
      } else {
        throw Exception('فشل تحميل البيانات (${response.statusCode})');
      }
    } catch (e) {
      // Try loading from cache
      final cached = await _loadFromCache();
      if (cached != null) {
        _surahs = cached;
        _dataSource = 'cache';
        _error = 'لا يوجد اتصال بالإنترنت - تم تحميل من الذاكرة المؤقتة';
      } else {
        _error = 'فشل تحميل البيانات. تأكد من اتصالك بالإنترنت.';
        _surahs = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Surah>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(AppConstants.cacheKeyData);
      if (cached != null) {
        final Map<String, dynamic> jsonData = json.decode(cached);
        final List<dynamic> surahsJson = jsonData['surahs'];
        return surahsJson
            .map((e) => Surah.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  List<Surah> search(String query) {
    if (query.isEmpty) return _surahs;
    final lowerQuery = query.toLowerCase();
    return _surahs.where((surah) {
      if (surah.name.toLowerCase().contains(lowerQuery)) return true;
      return surah.files.any((file) =>
          file.name.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
