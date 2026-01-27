// lib/models/item.dart
class NeoItem {
  final String id;
  final String title;
  final String? subtitle;
  final String category; // book, movie, tv, music, game, podcast
  final String coverUrl;
  final double rating;
  final int ratingCount;
  final String brief;
  final List<String> creators; // 作者、导演、艺术家等
  final String? pubDate;
  final Map<String, dynamic> metadata;

  NeoItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    required this.coverUrl,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.brief = '',
    this.creators = const [],
    this.pubDate,
    this.metadata = const {},
  });

  factory NeoItem.fromJson(Map<String, dynamic> json) {
    // 提取 ID
    String id = json['id'] ?? json['uuid'] ?? '';
    if (id.contains('/')) {
      final parts = id.split('/');
      id = parts.isNotEmpty ? parts.last : id;
    }

    // 处理创作者
    List<String> creators = [];
    if (json['author'] != null) {
      creators = _parseList(json['author']);
    } else if (json['director'] != null) {
      creators = _parseList(json['director']);
    } else if (json['artist'] != null) {
      creators = _parseList(json['artist']);
    } else if (json['developer'] != null) {
      creators = _parseList(json['developer']);
    }

    // 处理出版/发行日期
    String? pubDate;
    if (json['pub_date'] != null) {
      pubDate = json['pub_date'];
    } else if (json['pub_year'] != null) {
      pubDate = json['pub_year'].toString();
    } else if (json['release_date'] != null) {
      pubDate = json['release_date'];
    }

    // 获取封面 URL 并替换域名为可访问的镜像站
    String coverUrl = json['cover_image_url'] ?? '';
    if (coverUrl.isNotEmpty) {
      coverUrl = coverUrl.replaceAll('neodb.social', 'neodb.fyi');
    }

    return NeoItem(
      id: id,
      title: json['title'] ?? '未知标题',
      subtitle: json['subtitle'],
      category: json['category'] ?? 'book',
      coverUrl: coverUrl,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      brief: json['brief'] ?? json['description'] ?? '',
      creators: creators,
      pubDate: pubDate,
      metadata: json,
    ).._debugPrint();
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [value.toString()];
  }

  String get creatorsText => creators.isEmpty ? '未知' : creators.join(' / ');

  String get categoryName {
    const names = {
      'book': '图书',
      'movie': '电影',
      'tv': '剧集',
      'music': '音乐',
      'game': '游戏',
      'podcast': '播客',
    };
    return names[category] ?? category;
  }

  String get categoryIcon {
    const icons = {
      'book': '📚',
      'movie': '🎬',
      'tv': '📺',
      'music': '🎵',
      'game': '🎮',
      'podcast': '🎙️',
    };
    return icons[category] ?? '📄';
  }

  // 获取特定字段（不同类型有不同的字段）
  String? get publisher {
    return metadata['pub_house'] ?? metadata['publisher'];
  }

  int? get pages => metadata['pages'];

  String? get isbn => metadata['isbn'];

  int? get year => metadata['year'];

  String? get director {
    final dirs = metadata['director'];
    if (dirs is List && dirs.isNotEmpty) {
      return dirs.join(', ');
    }
    return dirs?.toString();
  }

  // 调试用
  void _debugPrint() {
    print('封面URL: $coverUrl');
  }
}