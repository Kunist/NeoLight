// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import '../models/review.dart';

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

  // 获取作品的短评列表
  // 注意：此 API 需要用户登录认证（Bearer Token）
  static Future<List<ShortReview>> getShortReviews({
    required String itemId,
    required String category,
    int page = 1,
    int pageSize = 10,
    String? accessToken,  // 访问令牌
  }) async {
    try {
      // 尝试不同的 API 路径格式
      final endpoints = [
        '$baseUrl/catalog/$category/$itemId/marks',
        '$baseUrl/$category/$itemId/marks',
        '$baseUrl/mark/$category/$itemId',
      ];

      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse(endpoint).replace(
            queryParameters: {
              'page': page.toString(),
              'page_size': pageSize.toString(),
            },
          );

          print('尝试短评 API: $uri');

          final headers = <String, String>{};
          if (accessToken != null) {
            headers['Authorization'] = 'Bearer $accessToken';
          }

          final response = await http.get(uri, headers: headers.isNotEmpty ? headers : null);

          if (response.statusCode == 200) {
            final data = json.decode(utf8.decode(response.bodyBytes));
            print('短评 API 响应: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}');

            if (data['data'] != null && data['data'] is List) {
              return (data['data'] as List)
                  .map((item) => ShortReview.fromJson(item))
                  .toList();
            } else if (data is List) {
              return (data as List)
                  .map((item) => ShortReview.fromJson(item))
                  .toList();
            }
          }
        } catch (e) {
          print('端点 $endpoint 失败: $e');
          continue;
        }
      }

      return [];
    } catch (e) {
      print('获取短评错误: $e');
      return [];
    }
  }

  // 获取作品的长评列表
  // 注意：此 API 需要用户登录认证（Bearer Token）
  static Future<List<LongReview>> getLongReviews({
    required String itemId,
    required String category,
    int page = 1,
    int pageSize = 10,
    String? accessToken,  // 访问令牌
  }) async {
    try {
      final endpoints = [
        '$baseUrl/catalog/$category/$itemId/reviews',
        '$baseUrl/$category/$itemId/reviews',
        '$baseUrl/review/$category/$itemId',
      ];

      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse(endpoint).replace(
            queryParameters: {
              'page': page.toString(),
              'page_size': pageSize.toString(),
            },
          );

          print('尝试长评 API: $uri');

          final headers = <String, String>{};
          if (accessToken != null) {
            headers['Authorization'] = 'Bearer $accessToken';
          }

          final response = await http.get(uri, headers: headers.isNotEmpty ? headers : null);

          if (response.statusCode == 200) {
            final data = json.decode(utf8.decode(response.bodyBytes));
            print('长评 API 响应: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}');

            if (data['data'] != null && data['data'] is List) {
              return (data['data'] as List)
                  .map((item) => LongReview.fromJson(item))
                  .toList();
            } else if (data is List) {
              return (data as List)
                  .map((item) => LongReview.fromJson(item))
                  .toList();
            }
          }
        } catch (e) {
          print('端点 $endpoint 失败: $e');
          continue;
        }
      }

      return [];
    } catch (e) {
      print('获取长评错误: $e');
      return [];
    }
  }

  // 获取混合评论列表（短评+长评）
  // 注意：此 API 需要用户登录认证（Bearer Token）
  static Future<List<Review>> getAllReviews({
    required String itemId,
    required String category,
    int page = 1,
    int pageSize = 10,
    String? accessToken,  // 访问令牌
  }) async {
    try {
      final endpoints = [
        '$baseUrl/catalog/$category/$itemId/comments',
        '$baseUrl/$category/$itemId/comments',
        '$baseUrl/catalog/$category/$itemId/marks',  // 如果没有 comments 端点，退回到 marks
        '$baseUrl/$category/$itemId/marks',
      ];

      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse(endpoint).replace(
            queryParameters: {
              'page': page.toString(),
              'page_size': pageSize.toString(),
            },
          );

          print('尝试评论 API: $uri');

          final headers = <String, String>{};
          if (accessToken != null) {
            headers['Authorization'] = 'Bearer $accessToken';
          }

          final response = await http.get(uri, headers: headers.isNotEmpty ? headers : null);

          if (response.statusCode == 200) {
            final data = json.decode(utf8.decode(response.bodyBytes));
            print('评论 API 响应: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}');

            List reviewList = [];
            if (data['data'] != null && data['data'] is List) {
              reviewList = data['data'] as List;
            } else if (data is List) {
              reviewList = data;
            }

            if (reviewList.isNotEmpty) {
              return reviewList.map((item) {
                // 根据是否有 title 判断是长评还是短评
                if (item['title'] != null && item['title'].toString().isNotEmpty) {
                  return LongReview.fromJson(item);
                } else {
                  return ShortReview.fromJson(item);
                }
              }).toList();
            }
          }
        } catch (e) {
          print('端点 $endpoint 失败: $e');
          continue;
        }
      }

      return [];
    } catch (e) {
      print('获取评论错误: $e');
      return [];
    }
  }
}