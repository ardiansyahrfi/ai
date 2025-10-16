import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/text_to_speech_page.dart';


/// ======================================================
/// 🧩 BASE SETUP: API BASE ADAPTIVE
/// ======================================================
String apiBase() {
  const localIp = '192.168.10.146'; // Ganti dengan IP laptop kamu
  if (kIsWeb) return 'http://localhost:3000';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  } catch (_) {}
  return 'http://$localIp:3000';
}

/// ======================================================
/// 🧭 ENUM MENU
/// ======================================================
enum HubMenu {
  tts,
  stt,
  widgets,
  editing,
  enhance,
  history,
  voices,
  createVoice,
}

/// ======================================================
/// 🏠 HUB PAGE UTAMA
/// ======================================================
class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  HubMenu _selected = HubMenu.tts;
  bool _isCollapsed = false;

  void _toggleSidebar() => setState(() => _isCollapsed = !_isCollapsed);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isMobile
          ? AppBar(
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
            )
          : null,
      drawer: isMobile
          ? _SideNav(
              selected: _selected,
              onSelect: (m) => setState(() => _selected = m),
              isCollapsed: false,
              onToggle: _toggleSidebar,
              isMobile: true,
            )
          : null,
      body: SafeArea(
        child: isMobile
            ? _ContentArea(selected: _selected)
            : Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isCollapsed ? 70 : 280,
                    child: _SideNav(
                      selected: _selected,
                      onSelect: (m) => setState(() => _selected = m),
                      isCollapsed: _isCollapsed,
                      onToggle: _toggleSidebar,
                      isMobile: false,
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

/// ======================================================
/// 📂 SIDENAV (NAVIGASI KIRI)
/// ======================================================
class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selected,
    required this.onSelect,
    required this.isCollapsed,
    required this.onToggle,
    required this.isMobile,
  });

  final HubMenu selected;
  final ValueChanged<HubMenu> onSelect;
  final bool isCollapsed;
  final VoidCallback onToggle;
  final bool isMobile;

  Widget _section(String text) => isCollapsed
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 0, 6),
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        );

  Widget _item(BuildContext context, HubMenu menu, IconData icon, String label) {
    final active = selected == menu;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          onSelect(menu);
          if (isMobile) Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE9F9F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12, vertical: 12),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon,
                  color:
                      active ? const Color(0xFF00C47D) : Colors.grey.shade700),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.normal,
                      color:
                          active ? const Color(0xFF00C47D) : Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Expand button di atas logo
          if (isCollapsed)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onToggle,
              tooltip: 'Expand sidebar',
            ),

          // Logo
          Padding(
            padding:
                EdgeInsets.fromLTRB(isCollapsed ? 0 : 20, 10, 20, isCollapsed ? 4 : 8),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                const Icon(Icons.graphic_eq, color: Color(0xFF00C47D)),
                if (!isCollapsed) ...[
                  const SizedBox(width: 8),
                  Text(
                    "RESEMBLE.AI",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF00C47D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.menu_open, color: Colors.black54),
                    onPressed: onToggle,
                    tooltip: 'Collapse sidebar',
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              children: [
                _section('Playground'),
                _item(context, HubMenu.tts, Icons.volume_up, 'Text-to-Speech'),
                _item(context, HubMenu.stt, Icons.mic, 'Speech-to-Text'),
                _item(context, HubMenu.widgets, Icons.widgets, 'Widgets'),
                _item(context, HubMenu.editing, Icons.music_note, 'Audio Editing'),
                _item(context, HubMenu.enhance, Icons.auto_fix_high, 'Audio Enhancement'),
                _item(context, HubMenu.history, Icons.history, 'History'),
                _section('Voice Design'),
                _item(context, HubMenu.voices, Icons.record_voice_over, 'My Voices'),
                _item(context, HubMenu.createVoice, Icons.add_circle_outline, 'Create Voice'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================
/// 🖥️ CONTENT AREA
/// ======================================================
class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.selected});
  final HubMenu selected;

  @override
  Widget build(BuildContext context) {
    final Map<HubMenu, Widget> pages = {
      HubMenu.tts: const TextToSpeechPage(),
      HubMenu.stt: const _SttPage(),
      HubMenu.widgets: const _PlaceholderPage('Widgets'),
      HubMenu.editing: const _PlaceholderPage('Audio Editing'),
      HubMenu.enhance: const _PlaceholderPage('Audio Enhancement'),
      HubMenu.history: const _PlaceholderPage('History'),
      HubMenu.voices: const _PlaceholderPage('My Voices'),
      HubMenu.createVoice: const _PlaceholderPage('Create New Voice'),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: pages[selected]!,
    );
  }
}

/// ======================================================
/// 🔊 TEXT TO SPEECH PAGE
/// ======================================================

/// ======================================================
/// 🎙 SPEECH TO TEXT PAGE
/// ======================================================
class _SttPage extends StatefulWidget {
  const _SttPage();

  @override
  State<_SttPage> createState() => _SttPageState();
}

class _SttPageState extends State<_SttPage> {
  bool uploading = false;
  String? result;

  Future<void> _pickAndTranscribe() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
      withData: kIsWeb,
    );
    if (picked == null) return;

    setState(() => uploading = true);

    try {
      final file = picked.files.first;
      final uri = Uri.parse('${apiBase()}/api/stt');
      final req = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        req.files.add(
            http.MultipartFile.fromBytes('audio', file.bytes!, filename: file.name));
      } else {
        req.files.add(await http.MultipartFile.fromPath('audio', file.path!));
      }

      final res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode == 200) {
        final data = jsonDecode(body);
        setState(() => result = data['output'] ?? '(kosong)');
      } else {
        setState(() => result = 'Gagal: $body');
      }
    } catch (e) {
      setState(() => result = 'Error: $e');
    } finally {
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: uploading
            ? const CircularProgressIndicator(color: Colors.green)
            : result == null
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload audio untuk diubah ke teks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C47D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    onPressed: _pickAndTranscribe,
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(result!,
                            style: GoogleFonts.poppins(fontSize: 16)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _pickAndTranscribe,
                          child: const Text('Upload lagi'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

/// ======================================================
/// 📄 PLACEHOLDER
/// ======================================================
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$title: Coming soon...',
          style: GoogleFonts.poppins(color: Colors.grey)),
    );
  }
}
