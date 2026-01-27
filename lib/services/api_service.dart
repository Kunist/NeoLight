// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiService {
  // 使用中国大陆可访问的域名
  static const String baseUrl = 'https://neodb.fyi/api';

  // 其他可用的域名：
  // static const String baseUrl = 'https://neodb.social/api';
  // static const String baseUrl = 'https://neodb.net.cn/api';

  // 搜索
  static Future<List<NeoItem>> search({
    required String query,
    String? category,
  }) async {
    try {
      final params = {
        'query': query,
        if (category != null && category != 'all') 'category': category,
      };

      final uri = Uri.parse('$baseUrl/catalog/search')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data['data'] != null && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => NeoItem.fromJson(item))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('搜索错误: $e');
      return [];
    }
  }

  // 获取详情
  static Future<NeoItem?> getDetail({
    required String id,
    required String category,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$category/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return NeoItem.fromJson(data);
      }

      return null;
    } catch (e) {
      print('获取详情错误: $e');
      return null;
    }
  }

  // 获取热门/趋势内容
  static Future<List<NeoItem>> getTrending({String? category}) async {
    try {
      // API 格式: /api/trending/{category}/
      // 例如: /api/trending/book/
      final endpoint = category != null && category != 'all'
          ? '$baseUrl/trending/$category/'
          : '$baseUrl/trending/';

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // API 可能返回 data 数组或直接是数组
        List items;
        if (data is Map && data['data'] != null) {
          items = data['data'] as List;
        } else if (data is List) {
          items = data;
        } else {
          return [];
        }

        return items.map((item) => NeoItem.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('获取热门内容错误: $e');
      return [];
    }
  }
}