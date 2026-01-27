// lib/pages/shelf_page.dart
import 'package:flutter/material.dart';

class ShelfPage extends StatelessWidget {
  const ShelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的标记'),
        backgroundColor: const Color(0xFFF6F6F6),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 80,
              color: const Color(0xFFF6F6F6),
            ),
            const SizedBox(height: 16),
            Text(
              '标记功能开发中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '未来可以查看：\n• 想看的内容\n• 在看的内容\n• 看过的内容',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}