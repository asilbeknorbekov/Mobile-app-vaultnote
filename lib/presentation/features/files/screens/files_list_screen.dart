import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:anote/core/icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../../../domain/entities/vault_file.dart';
import '../state/files_provider.dart';

class FilesListScreen extends ConsumerWidget {
  const FilesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(filesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: filesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (files) {
                    if (files.isEmpty) return _buildEmptyState();
                    return _buildFilesList(files);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(allowMultiple: false);
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.first;
            if (file.path != null) {
              final bytes = await File(file.path!).readAsBytes();
              final ext = p.extension(file.name).replaceAll('.', '');
              await ref.read(filesNotifierProvider).saveFile(file.name, ext, bytes);
            }
          }
        },
        child: const Icon(LucideIcons.plus, color: Colors.white),
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
            'Files & Media',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
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
          Icon(LucideIcons.folderOpen, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No files stored yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Securely upload PDFs, images, and audio.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList(List<VaultFile> files) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _FileCard(file: file),
        );
      },
    );
  }
}

class _FileCard extends StatelessWidget {
  final VaultFile file;

  const _FileCard({required this.file});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return LucideIcons.fileText;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return LucideIcons.image;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return LucideIcons.music;
      default:
        return LucideIcons.file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: () {
        OpenFilex.open(file.localPath);
      },
      child: GlassSurface(
        tier: GlassTier.tier3,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(file.fileType),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${file.fileType.toUpperCase()} • ${_formatSize(file.sizeBytes)} • ${dateFormat.format(file.createdAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.moreVertical, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
