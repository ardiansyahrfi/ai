import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SidebarMenu extends StatelessWidget {
  final Function()? onItemSelected;

  const SidebarMenu({super.key, this.onItemSelected});

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
                _buildMenuItem(Icons.volume_up, 'Text-to-Speech'),
                _buildMenuItem(Icons.change_circle, 'Voice Changer'),
                _buildMenuItem(Icons.keyboard_voice, 'Speech-to-Text'),
                _buildMenuItem(Icons.widgets, 'Widgets'),
                _buildMenuItem(Icons.music_note, 'Audio Editing'),
                _buildMenuItem(Icons.auto_fix_high, 'Audio Enhancement'),
                _buildMenuItem(Icons.history, 'History'),
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
                _buildMenuItem(Icons.record_voice_over, 'My Voices'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Upgrade button dihapus sesuai permintaan
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

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14),
      ),
      onTap: onItemSelected,
    );
  }
}
