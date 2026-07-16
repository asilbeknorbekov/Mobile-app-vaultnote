import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../../../domain/entities/note.dart';
import '../state/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  late String _noteId;
  late DateTime _createdAt;
  bool _isPinned = false;
  List<String> _tags = [];

  Timer? _debounce;
  
  @override
  void initState() {
    super.initState();
    _noteId = widget.existingNote?.id ?? const Uuid().v4();
    _createdAt = widget.existingNote?.createdAt ?? DateTime.now();
    _isPinned = widget.existingNote?.isPinned ?? false;
    _tags = widget.existingNote?.tags ?? [];

    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _saveNote();
    });
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    // Don't save empty notes
    if (title.isEmpty && content.isEmpty) return;

    final note = Note(
      id: _noteId,
      title: title,
      content: content,
      tags: _tags,
      isPinned: _isPinned,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    ref.read(notesProvider.notifier).saveNote(note);
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });
    _saveNote();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Start typing...',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return GlassSurface(
      tier: GlassTier.tier1,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () {
              _saveNote(); // Explicit save on back
              context.pop();
            },
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPinned ? LucideIcons.pinOff : LucideIcons.pin,
                  color: _isPinned ? Colors.blue : null,
                ),
                onPressed: _togglePin,
              ),
              IconButton(
                icon: const Icon(LucideIcons.moreVertical),
                onPressed: () {
                  // TODO: Show bottom sheet for tags, delete, etc.
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
