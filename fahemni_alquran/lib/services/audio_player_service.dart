import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fahemni_alquran/config/constants.dart';
import 'package:fahemni_alquran/models/audio_item.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<AudioItem> _playlist = [];
  int _currentIndex = 0;
  String _currentSurahName = '';
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<String> _favorites = [];
  bool _isShuffled = false;
  bool _isRepeating = false;

  AudioPlayerService() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading;
      notifyListeners();
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onComplete();
      }
    });

    _loadFavorites();
  }

  AudioPlayer get player => _player;
  List<AudioItem> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  String get currentSurahName => _currentSurahName;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  List<String> get favorites => _favorites;
  bool get isShuffled => _isShuffled;
  bool get isRepeating => _isRepeating;

  AudioItem? get currentItem =>
      _playlist.isNotEmpty && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;

  String get currentFileName => currentItem?.name ?? '';
  String get currentFileUrl => currentItem?.url ?? '';

  void setPlaylist(List<AudioItem> files, String surahName,
      {int initialIndex = 0}) {
    _playlist = files;
    _currentSurahName = surahName;
    _currentIndex = initialIndex;
    notifyListeners();

    if (files.isNotEmpty) {
      play();
      _saveLastPlayed();
    }
  }

  Future<void> play() async {
    if (_playlist.isEmpty) return;
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_playlist[_currentIndex].url)),
      );
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await play();
      _saveLastPlayed();
    }
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      await play();
      _saveLastPlayed();
    }
  }

  void _onComplete() {
    if (_isRepeating) {
      play();
    } else if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      play();
      _saveLastPlayed();
    }
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }

  Future<void> playFromIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await play();
      _saveLastPlayed();
    }
  }

  Future<void> _saveLastPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.cacheKeyLastSurah,
          _currentSurahName.hashCode);
      await prefs.setInt(AppConstants.cacheKeyLastFile, _currentIndex);
      final surahName = _currentSurahName;
      await prefs.setString(AppConstants.cacheKeyLastSurah, surahName);
    } catch (_) {}
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList(AppConstants.cacheKeyFavorites);
      if (favs != null) {
        _favorites = favs;
      }
    } catch (_) {}
  }

  Future<void> toggleFavorite(String fileUrl) async {
    if (_favorites.contains(fileUrl)) {
      _favorites.remove(fileUrl);
    } else {
      _favorites.add(fileUrl);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.cacheKeyFavorites, _favorites);
    notifyListeners();
  }

  bool isFavorite(String fileUrl) => _favorites.contains(fileUrl);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
