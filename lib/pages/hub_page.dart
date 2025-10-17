import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../pages/text_to_speech_page.dart';

/// ======================================================
/// BASE URL ADAPTIF (web / emulator / device fisik)
/// ======================================================
String apiBase() {
  const localIp = '192.168.100.89'; // ← ganti jika IP laptop berubah
  if (kIsWeb) return 'http://localhost:3000';
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
  } catch (_) {}
  return 'http://$localIp:3000';
}

/// ======================================================
/// ENUM MENU
/// ======================================================
enum HubMenu { tts, stt, widgets, editing, enhance, history, voices, createVoice }

/// ======================================================
/// HUB PAGE
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
              title: Text('RESEMBLE.AI',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00C47D),
                  )),
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
/// SIDENAV
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
          child: Text(text.toUpperCase(),
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
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
            mainAxisAlignment:
                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon,
                  color: active ? const Color(0xFF00C47D) : Colors.grey.shade700),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                      color: active ? const Color(0xFF00C47D) : Colors.black87,
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
          if (isCollapsed)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onToggle,
              tooltip: 'Expand sidebar',
            ),
          Padding(
            padding:
                EdgeInsets.fromLTRB(isCollapsed ? 0 : 20, 10, 20, isCollapsed ? 4 : 8),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                const Icon(Icons.graphic_eq, color: Color(0xFF00C47D)),
                if (!isCollapsed) ...[
                  const SizedBox(width: 8),
                  Text("RESEMBLE.AI",
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF00C47D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
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
/// CONTENT AREA
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
/// STT PAGE (UI mirip Resemble + upload jalan)
/// ======================================================
class _SttPage extends StatefulWidget {
  const _SttPage();

  @override
  State<_SttPage> createState() => _SttPageState();
}

class _SttPageState extends State<_SttPage> {
  bool _uploading = false;
  String? _transcript;

  Future<void> _pickAndTranscribe() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'm4a', 'mp3', 'wav', 'aac', 'ogg', 'flac', // audio
        'mp4', 'mov', 'mkv'                        // video
      ],
      withData: kIsWeb,
    );
    if (picked == null) return;

    final file = picked.files.first;
    setState(() {
      _uploading = true;
      _transcript = null;
    });

    try {
      // otomatis pilih endpoint sesuai ukuran
      final isBig = (file.size != null) && (file.size! >= 20 * 1024 * 1024);
      final uri = Uri.parse(
          '${apiBase()}${isBig ? '/api/stt/long-sync' : '/api/stt'}');

      final req = http.MultipartRequest('POST', uri)
        ..fields['language'] = 'auto';

      if (isBig) {
        // opsi segment untuk long-sync, biar cepat
        req.fields['segment'] = '300'; // 5 menit per segmen
      }

      if (kIsWeb) {
        req.files.add(http.MultipartFile.fromBytes(
          'audio',
          file.bytes!,
          filename: file.name,
        ));
      } else {
        req.files.add(await http.MultipartFile.fromPath('audio', file.path!));
      }

      final resp = await req.send();
      final body = await resp.stream.bytesToString();

      if (resp.statusCode == 200) {
        final data = jsonDecode(body);
        setState(() {
          final out = data['output']?.toString() ?? '';
          _transcript = out.trim().isEmpty ? '(Transkrip kosong)' : out;
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
    // Header: title + search + New Transcript
    Widget header() {
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
            Text('Speech-to-Text',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w600)),
            Row(
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search transcripts",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey[500]),
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
                  onPressed: _uploading ? null : _pickAndTranscribe,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: Text("New Transcript",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C47D),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

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
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            "Upload your first audio or video file to get started with\nspeech-to-text transcription.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _uploading ? null : _pickAndTranscribe,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: Text(
              _uploading ? "Uploading..." : "Upload Your First File",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C47D),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _uploading ? null : _pickAndTranscribe,
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

    return Column(
      children: [
        header(),
        Expanded(
          child: Center(
            child: _transcript == null ? emptyPanel : transcriptPanel,
          ),
        ),
      ],
    );
  }
}

/// ======================================================
/// PLACEHOLDER
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
