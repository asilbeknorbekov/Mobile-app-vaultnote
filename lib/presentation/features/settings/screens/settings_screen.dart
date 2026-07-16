import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../../data/datasources/local/database/backup_service.dart';
import 'package:file_picker/file_picker.dart';

final localAiModeProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localAiMode = ref.watch(localAiModeProvider);

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const _SectionHeader(title: 'Artificial Intelligence'),
              GlassSurface(
                tier: GlassTier.tier2,
                child: Column(children: [
                  SwitchListTile(
                    value: localAiMode,
                    onChanged: (val) => ref.read(localAiModeProvider.notifier).state = val,
                    title: const Text('Local-Only Mode'),
                    subtitle: const Text('Process AI securely on-device.'),
                    secondary: const Icon(LucideIcons.cpu),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.zap),
                    title: const Text('Cloud Token Usage'),
                    subtitle: const Text('2,450 / 100,000 monthly limit'),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () {},
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Appearance'),
              GlassSurface(
                tier: GlassTier.tier2,
                child: Column(children: [
                  ListTile(
                    leading: const Icon(LucideIcons.moon),
                    title: const Text('Theme'),
                    subtitle: Text(ref.watch(themeProvider).toString().split('.').last.toUpperCase()),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () {
                      final currentTheme = ref.read(themeProvider);
                      final nextTheme = currentTheme == ThemeMode.system 
                          ? ThemeMode.light 
                          : (currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.system);
                      ref.read(themeProvider.notifier).setTheme(nextTheme);
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Data & Backup'),
              GlassSurface(
                tier: GlassTier.tier2,
                child: Column(children: [
                  ListTile(
                    leading: const Icon(LucideIcons.downloadCloud),
                    title: const Text('Export Vault'),
                    subtitle: const Text('Save encrypted zip locally'),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () => _exportVault(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.uploadCloud),
                    title: const Text('Import Vault'),
                    subtitle: const Text('Restore from encrypted zip'),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () => _importVault(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.trash2, color: Colors.red),
                    title: const Text('Delete Vault', style: TextStyle(color: Colors.red)),
                    onTap: () {},
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportVault(BuildContext context) async {
    final password = await _promptPassword(context, 'Export Vault', 'Create a password to encrypt your backup.');
    if (password != null && password.isNotEmpty) {
      try {
        await BackupService().exportVault(password);
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importVault(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('WARNING'),
        content: const Text('Importing a vault will completely overwrite your current notes and files. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes, Overwrite', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final password = await _promptPassword(context, 'Import Vault', 'Enter the password you used to export this backup.');
        if (password != null && password.isNotEmpty) {
          try {
            await BackupService().importVault(path, password);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import successful. Please restart the app.')));
          } catch (e) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
          }
        }
      }
    }
  }

  Future<String?> _promptPassword(BuildContext context, String title, String message) {
    String pswd = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                onChanged: (v) => pswd = v,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, pswd), child: const Text('OK')),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
