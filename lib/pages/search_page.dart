// lib/pages/search_page.dart
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../widgets/item_card.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<NeoItem> _items = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _selectedCategory;

  final Map<String, String> _categories = {
    'all': '🌐 全部',
    'book': '📚 图书',
    'movie': '🎬 电影',
    'tv': '📺 剧集',
    'music': '🎵 音乐',
    'game': '🎮 游戏',
    'podcast': '🎙️ 播客',
  };

  @override
  void initState() {
    super.initState();
    // 延迟获取传递的参数并自动搜索
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyword = ModalRoute.of(context)?.settings.arguments as String?;
      if (keyword != null && keyword.isNotEmpty) {
        _searchController.text = keyword;
        _search();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入搜索关键词')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await ApiService.search(
        query: query,
        category: _selectedCategory,
      );

      setState(() {
        _items = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 分类选择器
          _buildCategoryTabs(),
          // 搜索结果
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索图书、电影、音乐...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _isLoading ? null : _search,
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _categories.entries.map((entry) {
          final isSelected = _selectedCategory == entry.key ||
              (_selectedCategory == null && entry.key == 'all');
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) async {
                setState(() {
                  _selectedCategory = entry.key == 'all' ? null : entry.key;
                });
                // 如果已经搜索过，自动重新搜索
                if (_hasSearched && _searchController.text.trim().isNotEmpty) {
                  await _search();  // 等待搜索完成
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('搜索中...'),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '输入关键词开始搜索',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关内容',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return ItemCard(
          item: _items[index],
          onTap: () => _navigateToDetail(_items[index]),
        );
      },
    );
  }
}
