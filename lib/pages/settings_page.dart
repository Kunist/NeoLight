// lib/pages/settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: const Color(0xFFF6F6F6),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // 用户信息
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  '未登录',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 登录功能
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('登录功能开发中...')),
                    );
                  },
                  child: const Text('登录 NeoDB'),
                ),
              ],
            ),
          ),
          const Divider(),
          // 设置项
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('主题设置'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('通知设置'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('缓存管理'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('关于'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'NeoDB',
                applicationVersion: '1.0.0',
                applicationLegalese: '非官方 NeoDB 客户端',
              );
            },
          ),
        ],
      ),
    );
  }
}