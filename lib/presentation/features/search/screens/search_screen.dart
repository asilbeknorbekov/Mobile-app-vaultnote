import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../notes/state/notes_provider.dart';
import '../../../../domain/entities/note.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: notesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text('Error: $err')),
                  data: (notes) {
                    final filteredNotes = _searchQuery.isEmpty 
                        ? <Note>[] 
                        : notes.where((n) => 
                            n.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            n.content.toLowerCase().contains(_searchQuery.toLowerCase())
                          ).toList();

                    if (_searchQuery.isNotEmpty && filteredNotes.isEmpty) {
                      return const Center(
                        child: Text('No results found.', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => context.push('/notes/${note.id}', extra: note),
                            child: GlassSurface(
                              tier: GlassTier.tier3,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title.isNotEmpty ? note.title : 'Untitled',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    note.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: GlassSurface(
              tier: GlassTier.tier2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(32),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search notes and files...',
                  border: InputBorder.none,
                  icon: const Icon(LucideIcons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
