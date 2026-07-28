class AudioItem {
  final String name;
  final String url;
  final String type;

  AudioItem({
    required this.name,
    required this.url,
    required this.type,
  });

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type,
    };
  }
}
