import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ResembleApp());
}

class ResembleApp extends StatelessWidget {
  const ResembleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Voice Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
