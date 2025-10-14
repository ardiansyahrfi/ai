import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import '../widgets/sidebar_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final player = AudioPlayer();

  bool _isLoading = false;
  String? _selectedVoice;

  // ===== Base URL adaptif (web/emulator/device) =====
  String apiBase() {
    // GANTI ini dengan IPv4 laptop kamu kalau pakai HP fisik
    const localIp = '192.168.1.10';

    if (kIsWeb) return 'http://localhost:3000';

    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // Android emulator
    } catch (_) {}

    // Device fisik (Android/iOS)
    return 'http://$localIp:3000';
  }

  Future<void> generateVoice(String text) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan teks terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${apiBase()}/api/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['output'] != null) {
          String audioUrl;

          // Bisa string atau list dari Replicate
          if (data['output'] is String) {
            audioUrl = data['output'];
          } else if (data['output'] is List && data['output'].isNotEmpty) {
            audioUrl = data['output'][0];
          } else {
            throw Exception("Output audio tidak ditemukan");
          }

          await player.setUrl(audioUrl);
          await player.play();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Audio berhasil diputar!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⏳ Masih diproses, coba lagi nanti.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarMenu(onItemSelected: () {
        Navigator.pop(context); // tutup drawer saat item dipilih
      }),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Text(
          'Text-to-Speech',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: _selectedVoice,
              items: const [
                DropdownMenuItem(value: 'Ember', child: Text('Ember')),
                DropdownMenuItem(value: 'Create a voice', child: Text('Create a voice')),
              ],
              onChanged: (val) => setState(() => _selectedVoice = val),
              hint: const Text('Select a voice'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Start typing your transcript here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chip: tetap tampilan sama, tapi bisa di-tap untuk isi teks
            Wrap(
              spacing: 8,
              children: [
                for (final tag in [
                  'Professional Advertisement Voiceover',
                  'Natural Conversation',
                  'Emotional Storytelling',
                  'Inspirational Travel Vlog',
                  'Customer Service Agent',
                  'Podcast Intro',
                  'E-learning Narrator',
                  'Character Voice',
                ])
                  GestureDetector(
                    onTap: () => setState(() => _textController.text = tag),
                    child: Chip(
                      label: Text(tag),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
              ],
            ),

            const Spacer(),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.play_circle_fill, size: 48, color: Colors.green),
                      onPressed: () => generateVoice(_textController.text),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
