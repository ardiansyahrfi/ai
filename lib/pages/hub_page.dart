import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// ===== Helper: Base URL adaptif (web / emulator / device) =====
String apiBase() {
  const localIp = '192.168.10.146'; // GANTI jika IP laptop berubah
  if (kIsWeb) return 'http://localhost:3000';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  } catch (_) {}
  return 'http://$localIp:3000';
}

/// ===== Enum menu =====
enum HubMenu { tts, stt, widgets, editing, enhance, history, voices, createVoice }

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  HubMenu _selected = HubMenu.tts;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 900;

    if (isNarrow) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'RESEMBLE.AI',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00C47D),
            ),
          ),
        ),
        drawer: _SideNav(
          selected: _selected,
          onSelect: (m) => setState(() => _selected = m),
        ),
        body: _ContentArea(selected: _selected),
      );
    }

    // Desktop/Web style: sidebar permanen
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 280,
              child: _SideNav(
                selected: _selected,
                onSelect: (m) => setState(() => _selected = m),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade200),
            Expanded(child: _ContentArea(selected: _selected)),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Sidebar permanen ----------------
class _SideNav extends StatelessWidget {
  const _SideNav({required this.selected, required this.onSelect});

  final HubMenu selected;
  final ValueChanged<HubMenu> onSelect;

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      );

  Widget _item(HubMenu m, IconData icon, String label) {
    final active = selected == m;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onSelect(m),
        child: Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE9F9F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: active ? const Color(0xFF00C47D) : Colors.black87),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: active ? const Color(0xFF00C47D) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq, color: Color(0xFF00C47D)),
                const SizedBox(width: 8),
                Text(
                  'RESEMBLE.AI',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00C47D),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.lock_outline, size: 18, color: Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _sectionHeader('Playground'),
          _item(HubMenu.tts, Icons.volume_up, 'Text-to-Speech'),
          _item(HubMenu.stt, Icons.keyboard_voice, 'Speech-to-Text'),
          _item(HubMenu.widgets, Icons.widgets, 'Widgets'),
          _item(HubMenu.editing, Icons.music_note, 'Audio Editing'),
          _item(HubMenu.enhance, Icons.auto_fix_high, 'Audio Enhancement'),
          _item(HubMenu.history, Icons.history, 'History'),
          _sectionHeader('Voice Design'),
          _item(HubMenu.voices, Icons.record_voice_over, 'My Voices'),
          _item(HubMenu.createVoice, Icons.add_circle_outline, 'Create New Voice'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF00C47D),
                  child: Text(
                    'R',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'rafhiardianzah@gmail.com',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                ),
                const Icon(Icons.settings, size: 18, color: Colors.black45),
                const SizedBox(width: 8),
                const Icon(Icons.notifications_none, size: 18, color: Colors.black45),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ---------------- Area konten kanan ----------------
class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.selected});
  final HubMenu selected;

  @override
  Widget build(BuildContext context) {
    Widget header({required String title, Widget? right}) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
            right ?? const SizedBox.shrink(),
          ],
        ),
      );
    }

    final searchAndNew = Row(
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search transcripts",
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New Transcript: coming soon')),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: Text(
            "New Transcript",
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C47D),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );

    final pages = {
      HubMenu.tts: Column(
        children: [
          header(title: 'Text-to-Speech'),
          const Expanded(child: _TtsView()),
        ],
      ),
      HubMenu.stt: Column(
        children: [
          header(title: 'Speech-to-Text', right: searchAndNew),
          const Expanded(child: _SttView()),
        ],
      ),
      HubMenu.widgets: _PlaceholderPage('Widgets'),
      HubMenu.editing: _PlaceholderPage('Audio Editing'),
      HubMenu.enhance: _PlaceholderPage('Audio Enhancement'),
      HubMenu.history: _PlaceholderPage('History'),
      HubMenu.voices: _PlaceholderPage('My Voices'),
      HubMenu.createVoice: _PlaceholderPage('Create New Voice'),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: pages[selected]!,
    );
  }
}

/// ---------------- TTS View ----------------
class _TtsView extends StatefulWidget {
  const _TtsView();

  @override
  State<_TtsView> createState() => _TtsViewState();
}

class _TtsViewState extends State<_TtsView> {
  final _textController = TextEditingController();
  final _player = AudioPlayer();
  String? _selectedVoice;
  bool _isLoading = false;

  Future<void> _generateVoice() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Masukkan teks terlebih dahulu')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final resp = await http.post(
        Uri.parse('${apiBase()}/api/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        String? audioUrl;
        if (data['output'] is String) {
          audioUrl = data['output'];
        } else if (data['output'] is List && data['output'].isNotEmpty) {
          audioUrl = data['output'][0];
        }
        if (audioUrl == null) throw Exception('Output audio tidak ditemukan');

        await _player.setUrl(audioUrl);
        await _player.play();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ Audio berhasil diputar!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ Gagal: ${resp.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            value: _selectedVoice,
            items: const [
              DropdownMenuItem(value: 'Ember', child: Text('Ember')),
              DropdownMenuItem(value: 'Create a voice', child: Text('Create a voice')),
            ],
            onChanged: (v) => setState(() => _selectedVoice = v),
            hint: const Text('Select a voice'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Start typing your transcript here...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
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
                  onTap: () => _textController.text = tag,
                  child: Chip(label: Text(tag), backgroundColor: Colors.grey[200]),
                ),
            ],
          ),
          const Spacer(),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.play_circle_fill, size: 48, color: Colors.green),
                    onPressed: _generateVoice,
                  ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- STT View (Upload berfungsi) ----------------
class _SttView extends StatefulWidget {
  const _SttView();

  @override
  State<_SttView> createState() => _SttViewState();
}

class _SttViewState extends State<_SttView> {
  bool _uploading = false;
  String? _transcript;

  Future<void> _pickAndUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m4a','mp3','wav','aac','ogg','flac','mp4','mov','mkv'],
        withData: kIsWeb,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      setState(() {
        _uploading = true;
        _transcript = null;
      });

      final uri = Uri.parse('${apiBase()}/api/stt');
      final req = http.MultipartRequest('POST', uri)..fields['language'] = 'auto';

      if (kIsWeb) {
        req.files.add(http.MultipartFile.fromBytes('audio', file.bytes!, filename: file.name));
      } else {
        req.files.add(await http.MultipartFile.fromPath('audio', file.path!));
      }

      final resp = await req.send();
      final body = await resp.stream.bytesToString();

      if (resp.statusCode == 200) {
        final data = jsonDecode(body);
        setState(() {
          _transcript = (data['output'] ?? '').toString().trim().isEmpty
              ? '(Transkrip kosong)'
              : data['output'].toString();
        });
      } else {
        setState(() => _transcript = 'Gagal: $body');
      }
    } catch (e) {
      setState(() => _transcript = 'Error: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emptyPanel = Container(
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 90, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text("No transcripts yet",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(
            "Upload your first audio or video file to get started with\nspeech-to-text transcription.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _uploading ? null : _pickAndUpload,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: Text(
              _uploading ? "Uploading..." : "Upload Your First File",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C47D),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          if (_uploading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Color(0xFF00C47D)),
          ],
        ],
      ),
    );

    final transcriptPanel = Container(
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text('Transcript Result',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _uploading ? null : _pickAndUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Another'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(minHeight: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Text(
                _transcript ?? '',
                style: GoogleFonts.poppins(fontSize: 14.5, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );

    return Center(child: _transcript == null ? emptyPanel : transcriptPanel);
  }
}

/// ---------------- Placeholder ----------------
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Center(
            child: Text('$title: coming soon', style: GoogleFonts.poppins(color: Colors.black54)),
          ),
        ),
      ],
    );
  }
}
