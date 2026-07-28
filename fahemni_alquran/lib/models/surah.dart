import 'package:fahemni_alquran/models/audio_item.dart';

class Surah {
  final String name;
  final String folder;
  final List<AudioItem> files;
  final int count;

  Surah({
    required this.name,
    required this.folder,
    required this.files,
    required this.count,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      name: json['name'] as String,
      folder: json['folder'] as String,
      files: (json['files'] as List)
          .map((e) => AudioItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'folder': folder,
      'files': files.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}
