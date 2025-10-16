import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class TextToSpeechPage extends StatefulWidget {
  const TextToSpeechPage({super.key});

  @override
  State<TextToSpeechPage> createState() => _TextToSpeechPageState();
}

class _TextToSpeechPageState extends State<TextToSpeechPage> {
  final AudioPlayer _player = AudioPlayer();
  final List<TextEditingController> _controllers = [TextEditingController()];
  int? speakingIndex;
  String selectedVoice = "Ember";
  bool _isLoading = false;
  String? _lastAudioUrl;

  final Map<String, String> _sampleTexts = {
    "Professional Advertisement Voiceover":
        "Temukan pengalaman baru bersama produk kami, dirancang khusus untuk memudahkan hidup Anda setiap hari.",
    "Natural Conversation":
        "Halo! Apa kabar hari ini? Aku harap semuanya berjalan lancar dan menyenangkan untukmu.",
    "Emotional Storytelling":
        "Di tengah malam yang sunyi, ia berdiri menatap langit, mengingat masa lalu yang tak pernah kembali.",
    "Inspirational Travel Vlog":
        "Akhirnya sampai juga di tempat ini! Udara yang segar dan pemandangan yang menakjubkan benar-benar membuatku kagum.",
    "Customer Service Agent":
        "Terima kasih telah menghubungi layanan pelanggan kami. Ada yang bisa kami bantu hari ini?",
    "Podcast Intro":
        "Selamat datang di Podcast Inspirasi, tempat di mana cerita dan ide bertemu untuk menginspirasi hidup Anda.",
    "E-learning Narrator":
        "Dalam pelajaran kali ini, kita akan mempelajari dasar-dasar pemrograman menggunakan bahasa Dart.",
    "Character Voice":
        "Hei! Aku di sini untuk membantumu menjalani petualangan seru ini. Siap? Ayo berangkat!",
  };

  // --- URL Backend Lokal ---
  String apiBase() {
    const localIp = '192.168.1.17'; // ganti sesuai IP lokal kamu
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://$localIp:3000';
  }

  // --- Fungsi Generate dan Mainkan Suara dari Server ---
  Future<void> _speakFromServer(String text, int index) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      speakingIndex = index;
    });

    try {
      final response = await http.post(
        Uri.parse('${apiBase()}/api/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['output'] != null && data['output'].isNotEmpty) {
          final audioUrl = data['output'][0];
          _lastAudioUrl = audioUrl;

          await _player.stop();
          await _player.setUrl("$audioUrl?ts=${DateTime.now().millisecondsSinceEpoch}");
          await _player.play();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Suara berhasil diputar')),
          );
        } else {
          throw Exception("Tidak ada output audio dari API.");
        }
      } else {
        throw Exception("Gagal memanggil API (${response.statusCode})");
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
        speakingIndex = null;
      });
    }
  }

  // --- Download Audio ke File ---
  Future<void> _downloadAudio() async {
    if (_lastAudioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada audio untuk diunduh')),
      );
      return;
    }

    final uri = Uri.parse(_lastAudioUrl!);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tts_audio_${DateTime.now().millisecondsSinceEpoch}.wav');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎧 Audio disimpan di: ${file.path}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengunduh audio')),
      );
    }
  }

  // --- Tambah / Hapus Textfield ---
  void _addTextField() => setState(() => _controllers.add(TextEditingController()));
  void _removeTextField(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  // --- Widget Text Area ---
  Widget _buildTextField(int index) {
    final controller = _controllers[index];
    final isSpeaking = speakingIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Start typing your transcript here...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            ),
            maxLines: null,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.play_circle_fill,
                  color: isSpeaking ? Colors.green : Colors.grey,
                  size: 36,
                ),
                onPressed: () => _speakFromServer(controller.text, index),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.translate, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.grey),
                onPressed: _downloadAudio,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _removeTextField(index),
              ),
            ],
          ),
          if (index == _controllers.length - 1)
            Center(
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                onPressed: _addTextField,
              ),
            ),
          const Divider(thickness: 0.8, height: 20),
        ],
      ),
    );
  }

  // --- Combo Box Ember ---
  Widget _buildVoiceSelector() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedVoice,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
              items: const [
                DropdownMenuItem(
                  value: "Ember",
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: Colors.black54),
                      SizedBox(width: 6),
                      Text("Ember"),
                    ],
                  ),
                ),
              ],
              onChanged: (value) => setState(() => selectedVoice = "Ember"),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {},
          child: Text(
            "or create a voice",
            style: GoogleFonts.poppins(color: Colors.teal, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _player.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVoiceSelector(),
            const SizedBox(height: 15),
            for (int i = 0; i < _controllers.length; i++) _buildTextField(i),
            const SizedBox(height: 20),
            Text("GET STARTED WITH",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sampleTexts.keys.map((label) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => setState(() => _controllers.first.text = _sampleTexts[label]!),
                  child: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(Icons.play_circle_fill,
                          color: speakingIndex != null ? Colors.green : Colors.grey[400], size: 60),
                      onPressed: () {
                        final allText = _controllers.map((c) => c.text.trim()).join(". ");
                        _speakFromServer(allText, 999);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
