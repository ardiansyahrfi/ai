import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SidebarMenu(onItemSelected: () {
        Navigator.pop(context); // menutup drawer saat item diklik
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
              items: const [
                DropdownMenuItem(value: 'Ember', child: Text('Ember')),
                DropdownMenuItem(value: 'Create a voice', child: Text('Create a voice')),
              ],
              onChanged: (_) {},
              hint: const Text('Select a voice'),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Start typing your transcript here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                  Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[200],
                  ),
              ],
            ),
            const Spacer(),
            Center(
              child: IconButton(
                icon: const Icon(Icons.play_circle_fill, size: 48, color: Colors.green),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
