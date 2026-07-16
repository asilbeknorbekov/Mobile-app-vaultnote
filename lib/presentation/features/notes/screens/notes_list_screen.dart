import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../../../domain/entities/note.dart';
import '../state/notes_provider.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: notesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (notes) {
                    if (notes.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    final sortedNotes = List<Note>.from(notes)
                      ..sort((a, b) {
                        if (a.isPinned && !b.isPinned) return -1;
                        if (!a.isPinned && b.isPinned) return 1;
                        return b.updatedAt.compareTo(a.updatedAt);
                      });
                      
                    return _buildNotesGrid(sortedNotes);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/new'),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return GlassSurface(
      tier: GlassTier.tier1,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bookOpen, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your second brain is empty.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to capture a thought.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid(List<Note> notes) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _NoteCard(note: note);
      },
    );
  }
}

class _NoteCard extends ConsumerWidget {
  final Note note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return GestureDetector(
      onTap: () => context.push('/notes/${note.id}', extra: note),
      child: GlassSurface(
        tier: GlassTier.tier2, // Use Tier 3 flat if performance suffers on older devices
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GlassSurface(
                  tier: GlassTier.tier3,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  borderRadius: BorderRadius.circular(6),
                  child: Text(
                    note.tags.first,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Text(
              note.title.isNotEmpty ? note.title : 'Untitled',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 4,
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(note.updatedAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (note.isPinned)
                  const Icon(LucideIcons.pin, size: 12, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
