import 'package:flutter/material.dart';
import 'pages/hub_page.dart'; // pastikan path benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APP AI',
      theme: ThemeData(useMaterial3: true),
      home: const HubPage(), // ⬅️ balik lagi ke HubPage!
    );
  }
}
