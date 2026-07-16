import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../notes/state/notes_provider.dart';
import '../../../../domain/entities/note.dart';
import '../../files/state/files_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // padding for bottom nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Text(
                        'Ready to remember?',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Add a giant search bar that acts as a button
                      GestureDetector(
                        onTap: () => context.push('/home/search'),
                        child: GlassSurface(
                          tier: GlassTier.tier2,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          borderRadius: BorderRadius.circular(32),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Search your vault...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vault Stats Card (Simulating Storage for now)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassSurface(
                    tier: GlassTier.tier2,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn(
                          icon: LucideIcons.database,
                          label: 'Vault Size',
                          value: notesAsync.maybeWhen(
                            data: (notes) => '${notes.length} items',
                            orElse: () => '...',
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                        const _StatColumn(
                          icon: LucideIcons.sparkles,
                          label: 'AI Usage',
                          value: '2% limit',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Quick Actions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _QuickActionCard(
                        icon: LucideIcons.penTool,
                        label: 'Write Note',
                        onTap: () => context.push('/notes/new'),
                      ),
                      _QuickActionCard(
                        icon: LucideIcons.mic,
                        label: 'Record Voice',
                        onTap: () async {
                          final speech = stt.SpeechToText();
                          bool available = await speech.initialize();
                          if (available) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Listening... Speak now.')),
                            );
                            speech.listen(
                              onResult: (result) {
                                if (result.finalResult) {
                                  final text = result.recognizedWords;
                                  final newNote = Note(
                                    id: const Uuid().v4(),
                                    title: 'Voice Note',
                                    content: text,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                    tags: [],
                                  );
                                  ref.read(notesProvider.notifier).saveNote(newNote);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Voice transcribed and saved as note.')),
                                  );
                                }
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Speech recognition not available on this device.')),
                            );
                          }
                        },
                      ),
                      _QuickActionCard(
                        icon: LucideIcons.scan,
                        label: 'Scan Doc',
                        onTap: () async {
                          final picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            final ext = p.extension(image.name).replaceAll('.', '');
                            await ref.read(filesProvider.notifier).saveFile(image.name, ext, bytes);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Document scanned and saved to Vault.')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Notes
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Recent Mind Drops',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                notesAsync.when(
                  data: (notes) {
                    if (notes.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text('Nothing here yet. Write a note!'),
                      );
                    }
                    final recent = notes.take(3).toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final note = recent[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () => context.push('/notes/${note.id}'),
                            child: GlassSurface(
                              tier: GlassTier.tier3,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.fileText, color: Colors.grey),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      note.title.isNotEmpty ? note.title : 'Untitled',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Text('Error: $err'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        child: GlassSurface(
          tier: GlassTier.tier2,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
