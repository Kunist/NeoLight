// lib/models/review.dart

/// 评论/短评基类
class Review {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String itemId;
  final String itemTitle;
  final String? itemCover;
  final String itemCategory;
  final double? rating;  // 评分 0-10
  final String? shelfType;  // 标记状态：wishlist, progress, complete
  final String createdTime;
  final String updatedTime;
  final String content;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final List<String> visibility;  // 可见性设置

  Review({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.itemId,
    required this.itemTitle,
    this.itemCover,
    required this.itemCategory,
    this.rating,
    this.shelfType,
    required this.createdTime,
    required this.updatedTime,
    required this.content,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.visibility = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['owner']?['url']?.toString() ?? '',
      username: json['owner']?['display_name']?.toString() ??
          json['owner']?['name']?.toString() ?? '匿名用户',
      userAvatar: json['owner']?['avatar']?.toString(),
      itemId: json['item']?['id']?.toString() ?? '',
      itemTitle: json['item']?['title']?.toString() ?? '',
      itemCover: json['item']?['cover_image_url']?.toString(),
      itemCategory: json['item']?['category']?.toString() ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      shelfType: json['shelf_type']?.toString(),
      createdTime: json['created_time']?.toString() ?? '',
      updatedTime: json['edited_time']?.toString() ?? json['created_time']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      likeCount: json['reaction_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['liked'] ?? false,
      visibility: json['visibility'] != null
          ? List<String>.from(json['visibility'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': {
        'url': userId,
        'display_name': username,
        'avatar': userAvatar,
      },
      'item': {
        'id': itemId,
        'title': itemTitle,
        'cover_image_url': itemCover,
        'category': itemCategory,
      },
      'rating': rating,
      'shelf_type': shelfType,
      'created_time': createdTime,
      'edited_time': updatedTime,
      'content': content,
      'reaction_count': likeCount,
      'comment_count': commentCount,
      'liked': isLiked,
      'visibility': visibility,
    };
  }

  // 获取标记状态的文字
  String get shelfTypeText {
    switch (shelfType) {
      case 'wishlist':
        return itemCategory == 'movie' || itemCategory == 'tv' ? '想看' : '想读';
      case 'progress':
        return itemCategory == 'movie' || itemCategory == 'tv' ? '在看' : '在读';
      case 'complete':
        return itemCategory == 'movie' || itemCategory == 'tv' ? '看过' : '读过';
      default:
        return '';
    }
  }

  // 获取评分显示（星星数量）
  double get starRating {
    if (rating == null) return 0;
    return rating! / 2; // 10分制转5分制
  }

  // 格式化时间显示
  String get timeAgo {
    try {
      final dateTime = DateTime.parse(createdTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}年前';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}个月前';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return createdTime;
    }
  }
}

/// 短评（Mark/Note）
class ShortReview extends Review {
  ShortReview({
    required super.id,
    required super.userId,
    required super.username,
    super.userAvatar,
    required super.itemId,
    required super.itemTitle,
    super.itemCover,
    required super.itemCategory,
    super.rating,
    super.shelfType,
    required super.createdTime,
    required super.updatedTime,
    required super.content,
    super.likeCount,
    super.commentCount,
    super.isLiked,
    super.visibility,
  });

  factory ShortReview.fromJson(Map<String, dynamic> json) {
    final review = Review.fromJson(json);
    return ShortReview(
      id: review.id,
      userId: review.userId,
      username: review.username,
      userAvatar: review.userAvatar,
      itemId: review.itemId,
      itemTitle: review.itemTitle,
      itemCover: review.itemCover,
      itemCategory: review.itemCategory,
      rating: review.rating,
      shelfType: review.shelfType,
      createdTime: review.createdTime,
      updatedTime: review.updatedTime,
      content: review.content,
      likeCount: review.likeCount,
      commentCount: review.commentCount,
      isLiked: review.isLiked,
      visibility: review.visibility,
    );
  }
}

/// 长评（Review）
class LongReview extends Review {
  final String? title;  // 长评标题

  LongReview({
    required super.id,
    required super.userId,
    required super.username,
    super.userAvatar,
    required super.itemId,
    required super.itemTitle,
    super.itemCover,
    required super.itemCategory,
    super.rating,
    super.shelfType,
    required super.createdTime,
    required super.updatedTime,
    required super.content,
    super.likeCount,
    super.commentCount,
    super.isLiked,
    super.visibility,
    this.title,
  });

  factory LongReview.fromJson(Map<String, dynamic> json) {
    final review = Review.fromJson(json);
    return LongReview(
      id: review.id,
      userId: review.userId,
      username: review.username,
      userAvatar: review.userAvatar,
      itemId: review.itemId,
      itemTitle: review.itemTitle,
      itemCover: review.itemCover,
      itemCategory: review.itemCategory,
      rating: review.rating,
      shelfType: review.shelfType,
      createdTime: review.createdTime,
      updatedTime: review.updatedTime,
      content: review.content,
      likeCount: review.likeCount,
      commentCount: review.commentCount,
      isLiked: review.isLiked,
      visibility: review.visibility,
      title: json['title']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['title'] = title;
    return json;
  }
}