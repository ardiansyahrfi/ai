import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart'; // untuk simpan file audio

class TextToSpeechPage extends StatefulWidget {
  const TextToSpeechPage({super.key});

  @override
  State<TextToSpeechPage> createState() => _TextToSpeechPageState();
}

class _TextToSpeechPageState extends State<TextToSpeechPage> {
  final TextEditingController _textController = TextEditingController();
  final player = AudioPlayer();
  bool _isLoading = false;
  String? _selectedVoice;

  String apiBase() {
    const localIp = '192.168.1.10'; // ganti sesuai IP lokal kamu
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
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
  await player.stop(); // pastikan tidak ada audio lama

  try {
    final response = await http.post(
      Uri.parse('${apiBase()}/api/tts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String audioUrl = data['output'] is String
          ? data['output']
          : (data['output'] as List).first;

      print('🔊 Audio URL: $audioUrl');

      // 🔥 Bersihkan cache & paksa reload URL baru
      await player.stop();
      await player.setUrl("$audioUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}");
      await player.play();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Audio berhasil diputar!')),
      );
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

  Future<void> translateText() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${apiBase()}/api/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"text": _textController.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _textController.text = data['translatedText'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjemahan gagal.')),
        );
      }
    } catch (e) {
      debugPrint('Translate error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> downloadAudio() async {
    // contoh simulasi unduh audio
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎧 Audio berhasil diunduh!')),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      'Professional Advertisement Voiceover',
      'Natural Conversation',
      'Emotional Storytelling',
      'Inspirational Travel Vlog',
      'Customer Service Agent',
      'Podcast Intro',
      'E-learning Narrator',
      'Character Voice',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Header Voice Selector ===
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      value: _selectedVoice,
                      items: const [
                        DropdownMenuItem(
                            value: 'Ember', child: Text('Ember')),
                        DropdownMenuItem(
                            value: 'Create', child: Text('Create a voice')),
                      ],
                      onChanged: (val) => setState(() => _selectedVoice = val),
                      hint: const Text('Select a voice'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "create a voice",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      elevation: 0,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.settings, color: Colors.black54),
                    label: const Text(
                      "Voice Settings",
                      style: TextStyle(color: Colors.black87),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // === Input Text Area ===
              TextField(
                controller: _textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Start typing your transcript here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // === "Get Started With" ===
              Text(
                "GET STARTED WITH",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map((text) => GestureDetector(
                          onTap: () => setState(() {
                            _textController.text = text;
                          }),
                          child: Chip(
                            label: Text(
                              text,
                              style: const TextStyle(fontSize: 13),
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                        ))
                    .toList(),
              ),
              const Spacer(),

              // === Bottom Buttons ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill,
                        size: 64,
                        color: Colors.green,
                      ),
                      onPressed: () => generateVoice(_textController.text),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: translateText,
                    icon: const Icon(Icons.translate, color: Colors.grey),
                    label: const Text(
                      "Translate",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: downloadAudio,
                    icon: const Icon(Icons.download, color: Colors.grey),
                    label: const Text(
                      "Download",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
