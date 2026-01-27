// lib/pages/detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class DetailPage extends StatefulWidget {
  final NeoItem item;

  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  NeoItem? _detailItem;
  bool _isLoading = true;
  bool _showFullBrief = false;  // 控制简介展开

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await ApiService.getDetail(
        id: widget.item.id,
        category: widget.item.category,
      );

      setState(() {
        _detailItem = detail ?? widget.item;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _detailItem = widget.item;
        _isLoading = false;
      });
    }
  }

  // 显示详细信息底部弹窗
  void _showDetailSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _detailItem ?? widget.item;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('发现'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(item),
            const SizedBox(height: 16),
            // _buildActionButtons(item),
            // const SizedBox(height: 16),
            _buildBrief(item),
            const SizedBox(height: 16),
            _buildReviews(item),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // 头部：封面和基本信息
  Widget _buildHeader(NeoItem item) {
    final isSquareCover = item.category == 'music' || item.category == 'podcast';
    final coverSize = isSquareCover ? 112.0 : 112.0;
    final coverHeight = isSquareCover ? 112.0 : 160.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.coverUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: item.coverUrl,
              width: coverSize,
              height: coverHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: coverSize,
                height: coverHeight,
                color: Colors.grey[200],
              ),
              errorWidget: (context, url, error) {
                return Container(
                  width: coverSize,
                  height: coverHeight,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      item.categoryIcon,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                );
              },
            )
                : Container(
              width: coverSize,
              height: coverHeight,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  item.categoryIcon,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 右侧信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 中文标题
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                // 原名（如果有且不同于标题）
                if (item.metadata['orig_title'] != null &&
                    item.metadata['orig_title'] != item.title) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.metadata['orig_title'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                // 评分
                if (item.rating > 0)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${item.ratingCount})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                // 简略信息（可点击查看更多）- 箭头在文字末尾
                InkWell(
                  onTap: _showDetailSheet,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      // color: Colors.grey[100],
                      // borderRadius: BorderRadius.circular(6),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: _getShortInfo(item)),
                          TextSpan(
                            text: ' >',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 三个按钮
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactActionButton(
                        icon: Icons.favorite_outline,
                        label: item.category == 'movie' || item.category == 'tv' ? '想看' : '想读',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactActionButton(
                        icon: Icons.radio_button_checked_outlined,
                        label: item.category == 'movie' || item.category == 'tv' ? '在看' : '在读',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactActionButton(
                        icon: Icons.star_outline,
                        label: item.category == 'movie' || item.category == 'tv' ? '看过' : '读过',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取简略信息文本
  String _getShortInfo(NeoItem item) {
    final parts = <String>[];

    if (item.category == 'book') {
      parts.add(item.creatorsText);
      if (item.publisher != null) parts.add(item.publisher!);
      if (item.pubDate != null) parts.add(item.pubDate!);
      if (item.pages != null) parts.add('${item.pages}页');
    } else if (item.category == 'movie' || item.category == 'tv') {
      parts.add(item.creatorsText);
      if (item.year != null) parts.add('${item.year}');
      if (item.metadata['area'] != null) {
        final areas = item.metadata['area'];
        if (areas is List) parts.add(areas.join(' / '));
        else parts.add(areas.toString());
      }
    } else if (item.category == 'music') {
      parts.add(item.creatorsText);
      if (item.pubDate != null) parts.add(item.pubDate!);
      if (item.metadata['genre'] != null) {
        final genres = item.metadata['genre'];
        if (genres is List) parts.add(genres.join(' / '));
        else parts.add(genres.toString());
      }
    }

    return parts.join(' / ');
  }

  // 紧凑的操作按钮（用于头部）
  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // 操作按钮
  Widget _buildActionButtons(NeoItem item) {
    // 根据类型决定按钮文字
    final isVideo = item.category == 'movie' || item.category == 'tv';
    final labels = isVideo
        ? ['想看', '在看', '看过']
        : ['想读', '在读', '读过'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.favorite_outline,
              label: labels[0],
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.radio_button_checked_outlined,
              label: labels[1],
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.star_outline,
              label: labels[2],
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // 简介
  Widget _buildBrief(NeoItem item) {
    if (item.brief.isEmpty) return const SizedBox.shrink();

    // 判断是否需要显示"更多"按钮
    final briefLines = item.brief.split('\n').length;
    final needsExpand = briefLines > 5 || item.brief.length > 200;

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '简介',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (needsExpand)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showFullBrief = !_showFullBrief;
                    });
                  },
                  child: Text(_showFullBrief ? '收起' : '更多'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.brief,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
            maxLines: _showFullBrief ? null : 5,
            overflow: _showFullBrief ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 短评列表（模拟数据，实际需要调用评论API）
  Widget _buildReviews(NeoItem item) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '短评',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),
          _buildReviewItem(
            username: 'selenophilia',
            avatar: '🐱',
            time: '4周前',
            rating: 3.5,
            status: '读过',
            title: item.title,
            content: '读了一部分',
            likes: 0,
          ),
          const Divider(height: 24),
          _buildReviewItem(
            username: '爱果',
            avatar: '👤',
            time: '4个月前',
            rating: 4.5,
            status: '读过',
            title: item.title,
            content: '很好读，不过实操部分有点少',
            likes: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String username,
    required String avatar,
    required String time,
    required double rating,
    required String status,
    required String title,
    required String content,
    required int likes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户信息
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: Text(avatar, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 评分和状态
        Row(
          children: [
            Text(
              status,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 星级评分
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(Icons.star, size: 16, color: Colors.orange[700]);
            } else if (index < rating) {
              return Icon(Icons.star_half, size: 16, color: Colors.orange[700]);
            } else {
              return Icon(Icons.star_outline, size: 16, color: Colors.grey[400]);
            }
          }),
        ),
        const SizedBox(height: 8),
        // 评论内容
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 8),
        // 点赞
        Row(
          children: [
            Icon(Icons.favorite_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '$likes',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  // 详细信息半屏弹窗
  Widget _buildDetailSheet() {
    final item = _detailItem ?? widget.item;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖动条
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '详细信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          // 详细信息内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildDetailInfo(item),
            ),
          ),
        ],
      ),
    );
  }

  // 根据不同类型显示不同的详细信息
  Widget _buildDetailInfo(NeoItem item) {
    if (item.category == 'book') {
      return _buildBookDetail(item);
    } else if (item.category == 'movie' || item.category == 'tv') {
      return _buildMovieDetail(item);
    } else if (item.category == 'music') {
      return _buildMusicDetail(item);
    } else if (item.category == 'game') {
      return _buildGameDetail(item);
    } else {
      return _buildCommonDetail(item);
    }
  }

  // 图书详细信息
  Widget _buildBookDetail(NeoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('书名', item.title),
        if (item.metadata['orig_title'] != null)
          _infoRow('原名', item.metadata['orig_title']),
        if (item.subtitle != null)
          _infoRow('副标题', item.subtitle!),
        _infoRow('作者', item.creatorsText),
        if (item.metadata['translator'] != null)
          _infoRow('译者', _parseList(item.metadata['translator'])),
        if (item.publisher != null)
          _infoRow('出版社', item.publisher!),
        if (item.pubDate != null)
          _infoRow('出版时间', item.pubDate!),
        if (item.pages != null)
          _infoRow('页数', '${item.pages}'),
        if (item.metadata['binding'] != null)
          _infoRow('装帧', item.metadata['binding']),
        if (item.metadata['price'] != null)
          _infoRow('定价', item.metadata['price']),
        if (item.isbn != null)
          _infoRowWithCopy('ISBN', item.isbn!),
        if (item.metadata['series'] != null)
          _infoRow('丛书', item.metadata['series']),
      ],
    );
  }

  // 影视详细信息
  Widget _buildMovieDetail(NeoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(item.category == 'movie' ? '电影名' : '剧名', item.title),
        if (item.metadata['orig_title'] != null)
          _infoRow('原名', item.metadata['orig_title']),
        if (item.metadata['director'] != null)
          _infoRow('导演', _parseList(item.metadata['director'])),
        if (item.metadata['playwright'] != null)
          _infoRow('编剧', _parseList(item.metadata['playwright'])),
        if (item.metadata['actor'] != null)
          _infoRow('主演', _parseList(item.metadata['actor'])),
        if (item.metadata['genre'] != null)
          _infoRow('类型', _parseList(item.metadata['genre'])),
        if (item.metadata['area'] != null)
          _infoRow('制片国家/地区', _parseList(item.metadata['area'])),
        if (item.metadata['language'] != null)
          _infoRow('语言', _parseList(item.metadata['language'])),
        if (item.pubDate != null)
          _infoRow('上映日期', item.pubDate!),
        if (item.metadata['duration'] != null)
          _infoRow('片长', item.metadata['duration']),
        if (item.metadata['season_count'] != null)
          _infoRow('季数', '${item.metadata['season_count']}'),
        if (item.metadata['episode_count'] != null)
          _infoRow('集数', '${item.metadata['episode_count']}'),
        if (item.metadata['imdb_code'] != null)
          _infoRowWithCopy('IMDb', item.metadata['imdb_code']),
      ],
    );
  }

  // 音乐详细信息
  Widget _buildMusicDetail(NeoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('专辑', item.title),
        if (item.metadata['orig_title'] != null)
          _infoRow('原名', item.metadata['orig_title']),
        _infoRow('艺术家', item.creatorsText),
        if (item.metadata['genre'] != null)
          _infoRow('流派', _parseList(item.metadata['genre'])),
        if (item.pubDate != null)
          _infoRow('发行时间', item.pubDate!),
        if (item.publisher != null)
          _infoRow('唱片公司', item.publisher!),
        if (item.metadata['track_count'] != null)
          _infoRow('曲目数', '${item.metadata['track_count']}'),
        if (item.metadata['duration'] != null)
          _infoRow('时长', item.metadata['duration']),
      ],
    );
  }

  // 游戏详细信息
  Widget _buildGameDetail(NeoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('游戏名', item.title),
        if (item.metadata['orig_title'] != null)
          _infoRow('原名', item.metadata['orig_title']),
        if (item.metadata['developer'] != null)
          _infoRow('开发商', _parseList(item.metadata['developer'])),
        if (item.metadata['publisher'] != null)
          _infoRow('发行商', _parseList(item.metadata['publisher'])),
        if (item.metadata['genre'] != null)
          _infoRow('类型', _parseList(item.metadata['genre'])),
        if (item.metadata['platform'] != null)
          _infoRow('平台', _parseList(item.metadata['platform'])),
        if (item.pubDate != null)
          _infoRow('发行日期', item.pubDate!),
      ],
    );
  }

  // 通用详细信息
  Widget _buildCommonDetail(NeoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('标题', item.title),
        if (item.metadata['orig_title'] != null)
          _infoRow('原名', item.metadata['orig_title']),
        _infoRow('创作者', item.creatorsText),
        if (item.pubDate != null)
          _infoRow('日期', item.pubDate!),
      ],
    );
  }

  // 信息行
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 可复制的信息行
  Widget _infoRowWithCopy(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label 已复制')),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 解析列表或字符串
  String _parseList(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.join(' / ');
    }
    return value.toString();
  }
}