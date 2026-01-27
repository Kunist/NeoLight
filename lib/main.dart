// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/search_page.dart';

void main() {
  runApp(const NeoApp());
}

class NeoApp extends StatelessWidget {
  const NeoApp({super.key});

  // 统一颜色定义
  static const Color navigationBarColor = Color(0xFFF8F8FF);  // 导航栏颜色
  static const Color backgroundColor = Color(0xFFF0F0F8);     // 背景色（比导航栏浅）

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoDB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        // 统一设置背景色
        scaffoldBackgroundColor: backgroundColor,
        // 统一设置 AppBar 颜色
        appBarTheme: const AppBarTheme(
          backgroundColor: navigationBarColor,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        // 统一设置底部导航栏颜色
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: navigationBarColor,
          elevation: 0,
          indicatorColor: Colors.teal.withOpacity(0.2),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainPage(),
      routes: {
        '/search': (context) => const SearchPage(),
      },
    );
  }
}