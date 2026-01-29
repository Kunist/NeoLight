// lib/pages/discover_page.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin {
  final Map<String, List<NeoItem>> _categoryItems = {};
  final Map<String, bool> _loading = {};

  final List<Map<String, String>> _categories = [
    {'key': 'book', 'name': '图书', 'icon': '📚'},
    {'key': 'movie', 'name': '电影', 'icon': '🎬'},
    {'key': 'tv', 'name': '剧集', 'icon': '📺'},
    {'key': 'music', 'name': '音乐', 'icon': '🎵'},
    {'key': 'game', 'name': '游戏', 'icon': '🎮'},
    {'key': 'podcast', 'name': '播客', 'icon': '🎙️'},
  ];

  // 搜索相关
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<String> _searchHistory = [];
  List<NeoItem> _searchResults = [];
  bool _isSearchLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTrendingItems();
    _loadSearchHistory();

    // 监听焦点变化
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 加载搜索历史
  Future<void> _loadSearchHistory() async {
    setState(() {
      _searchHistory = ['三体', '肖申克的救赎', '周杰伦'];
    });
  }

  // 保存搜索历史
  Future<void> _saveSearchHistory(String keyword) async {
    if (keyword.isEmpty) return;

    setState(() {
      _searchHistory.remove(keyword);
      _searchHistory.insert(0, keyword);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
  }

  // 清除搜索历史
  Future<void> _clearSearchHistory() async {
    setState(() {
      _searchHistory.clear();
    });
  }

  // 搜索建议（实时）
  Future<void> _searchSuggestions(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearchLoading = true;
    });

    try {
      final results = await ApiService.search(query: keyword);
      setState(() {
        _searchResults = results.take(5).toList();
        _isSearchLoading = false;
      });
    } catch (e) {
      setState(() {
        _isSearchLoading = false;
      });
    }
  }

  // 完整搜索（按下搜索键）
  void _performFullSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    _saveSearchHistory(keyword);
    _searchFocusNode.unfocus();

    // 跳转到搜索结果页面
    Navigator.pushNamed(
      context,
      '/search',
      arguments: keyword,
    );

    // 清空输入框并取消搜索状态
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _searchResults.clear();
    });
  }

  // 取消搜索
  void _cancelSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _searchResults.clear();
    });
  }

  Future<void> _loadTrendingItems() async {
    final futures = _categories.map((category) async {
      final key = category['key']!;
      setState(() {
        _loading[key] = true;
      });

      try {
        final items = await ApiService.getTrending(category: key);
        setState(() {
          _categoryItems[key] = items.take(10).toList();
          _loading[key] = false;
        });
      } catch (e) {
        print('加载 $key 失败: $e');
        setState(() {
          _categoryItems[key] = [];
          _loading[key] = false;
        });
      }
    });

    await Future.wait(futures);
  }

  void _navigateToDetail(NeoItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      child: Scaffold(
        body: _isSearching
            ? Column(
          children: [
            _buildCustomAppBar(),
            Expanded(child: _buildSearchContent()),
          ],
        )
            : _buildDiscoverContentWithSliver(),
      ),
    );
  }

  // 自定义顶部栏
  Widget _buildCustomAppBar() {
    // 从 main.dart 获取统一颜色
    final navigationBarColor = Theme.of(context).appBarTheme.backgroundColor!;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: _isSearching ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: _isSearching ? Colors.white : navigationBarColor,  // 使用主题颜色
        boxShadow: _isSearching
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isSearching) ...[
            const SizedBox(height: 12),
            const Text(
              '发现',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 8),
          ],
          _buildSearchBar(),
        ],
      ),
    );
  }

  // 搜索框
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: '搜索图书、电影、音乐...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: _isSearching ? Colors.grey[100] : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              _searchSuggestions(value);
            },
            onSubmitted: (value) {
              _performFullSearch(value);
            },
          ),
        ),
        if (_isSearching) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: _cancelSearch,
            child: const Text('取消', style: TextStyle(fontSize: 14)),
          ),
        ],
      ],
    );
  }

  // 搜索内容（搜索建议 + 搜索历史）
  Widget _buildSearchContent() {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 搜索建议
          if (_searchController.text.trim().isNotEmpty && _searchResults.isNotEmpty) ...[
            Text(
              '搜索建议',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            ..._searchResults.map((item) => _buildSuggestionItem(item)),
            const SizedBox(height: 24),
          ],

          // 搜索历史
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('清除搜索历史'),
                        content: const Text('确定要清除所有搜索历史吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              _clearSearchHistory();
                              Navigator.pop(context);
                            },
                            child: const Text('清除'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('清除', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((keyword) {
                return InkWell(
                  onTap: () {
                    _searchController.text = keyword;
                    _performFullSearch(keyword);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _isSearching ? Colors.white : Colors.grey[50],
                      boxShadow: _isSearching
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          keyword,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else if (_searchController.text.trim().isEmpty) ...[
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    '输入关键词搜索图书、电影、音乐...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 搜索建议条目
  Widget _buildSuggestionItem(NeoItem item) {
    return InkWell(
      onTap: () => _navigateToDetail(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: item.coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: item.coverUrl,
                width: 40,
                height: 55,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 40,
                  height: 55,
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    width: 40,
                    height: 55,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        item.categoryIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              )
                  : Container(
                width: 40,
                height: 55,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    item.categoryIcon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.categoryName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (item.creatorsText.isNotEmpty) ...[
                        Text(' · ', style: TextStyle(color: Colors.grey[400])),
                        Expanded(
                          child: Text(
                            item.creatorsText,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.north_west, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }


  // 使用 Sliver 的发现内容
  Widget _buildDiscoverContentWithSliver() {
    final navigationBarColor = Theme.of(context).appBarTheme.backgroundColor!;

    return RefreshIndicator(
      onRefresh: _loadTrendingItems,
      child: CustomScrollView(
        slivers: [
          // SliverAppBar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            snap: false,
            backgroundColor: navigationBarColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: null,
              background: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  bottom: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '发现',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSearchBar(),
                  ],
                ),
              ),
            ),
          ),
          // 内容列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final category = _categories[index];
                return _buildCategorySection(
                  category['key']!,
                  category['name']!,
                  category['icon']!,
                );
              },
              childCount: _categories.length,
            ),
          ),
        ],
      ),
    );
  }
  // 发现内容
  Widget _buildDiscoverContent() {
    return RefreshIndicator(
      onRefresh: _loadTrendingItems,
      child: ListView(
        children: _categories.map((category) {
          return _buildCategorySection(
            category['key']!,
            category['name']!,
            category['icon']!,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(String key, String name, String icon) {
    final items = _categoryItems[key] ?? [];
    final isLoading = _loading[key] ?? false;
    final isSquareCategory = key == 'music' || key == 'podcast';
    final sectionHeight = isSquareCategory ? 130.0 : 160.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
            ],
          ),
        ),
        SizedBox(
          height: sectionHeight,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? const Center(child: Text('暂无内容'))
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(items[index]);
            },
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  Widget _buildItemCard(NeoItem item) {
    final isSquareCover = item.category == 'music' || item.category == 'podcast';
    final coverHeight = isSquareCover ? 90.0 : 120.0;

    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => _navigateToDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: item.coverUrl,
                width: 90,
                height: coverHeight,
                fit: BoxFit.cover,
                memCacheWidth: 180,
                memCacheHeight: isSquareCover ? 180 : 240,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => Container(
                  width: 90,
                  height: coverHeight,
                  color: Colors.grey[200],
                ),
                errorWidget: (context, url, error) {
                  return _buildPlaceholder(item, coverHeight);
                },
              )
                  : _buildPlaceholder(item, coverHeight),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(NeoItem item, double coverHeight) {
    return Container(
      width: 90,
      height: coverHeight,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          item.categoryIcon,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}