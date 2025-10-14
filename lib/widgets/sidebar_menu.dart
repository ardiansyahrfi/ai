import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Halaman
import '../pages/home_page.dart';
import '../pages/speech_to_text.dart';

class SidebarMenu extends StatelessWidget {
  final Function()? onItemSelected; // opsional callback global

  const SidebarMenu({super.key, this.onItemSelected});

  // Helper: tutup drawer lalu navigate (biar animasi halus)
  void _go(BuildContext context, Widget page, {bool replace = false}) {
    Navigator.pop(context);                 // tutup drawer
    onItemSelected?.call();                 // callback opsional
    // delay microtask agar penutupan drawer selesai dulu
    Future.microtask(() {
      if (replace) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => page),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => page),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[50],
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                Icon(Icons.graphic_eq, color: Colors.green[600], size: 28),
                const SizedBox(width: 8),
                Text(
                  'RESEMBLE.AI',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                // Text-to-Speech → kembali ke HomePage
                _buildMenuItem(
                  context,
                  Icons.volume_up,
                  'Text-to-Speech',
                  () => _go(context, const HomePage(), replace: true),
                ),

                // Voice Changer (placeholder)
                _buildMenuItem(
                  context,
                  Icons.change_circle,
                  'Voice Changer',
                  () {
                    Navigator.pop(context);
                    onItemSelected?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice Changer: coming soon')),
                    );
                  },
                ),

                // ===== Speech-to-Text → buka halaman STT =====
                _buildMenuItem(
                  context,
                  Icons.keyboard_voice,
                  'Speech-to-Text',
                  () => _go(context, const SpeechToTextPage()),
                ),

                // Widgets (placeholder)
                _buildMenuItem(
                  context,
                  Icons.widgets,
                  'Widgets',
                  () {
                    Navigator.pop(context);
                    onItemSelected?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Widgets: coming soon')),
                    );
                  },
                ),

                // Audio Editing (placeholder)
                _buildMenuItem(
                  context,
                  Icons.music_note,
                  'Audio Editing',
                  () {
                    Navigator.pop(context);
                    onItemSelected?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio Editing: coming soon')),
                    );
                  },
                ),

                // Audio Enhancement (placeholder)
                _buildMenuItem(
                  context,
                  Icons.auto_fix_high,
                  'Audio Enhancement',
                  () {
                    Navigator.pop(context);
                    onItemSelected?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio Enhancement: coming soon')),
                    );
                  },
                ),

                // History (placeholder)
                _buildMenuItem(
                  context,
                  Icons.history,
                  'History',
                  () {
                    Navigator.pop(context);
                    onItemSelected?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('History: coming soon')),
                    );
                  },
                ),

                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Voice Design',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                // My Voices (placeholder)
                _buildMenuItem(
                  context,
                  Icons.record_voice_over,
                  'My Voices',
                  () {
                    Navigator.pop(context);
                    onItemSelected?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('My Voices: coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              'mutiarisnawati1212@gmail.com',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  // Versi _buildMenuItem yang menerima callback onTap spesifik
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      onTap: onTap,
    );
  }
}
