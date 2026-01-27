// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'pages/search_page.dart';

void main() {
  runApp(const NeoApp());
}

class NeoApp extends StatelessWidget {
  const NeoApp({super.key});

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