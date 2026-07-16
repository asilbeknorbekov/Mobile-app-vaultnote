import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultnote/core/icons/lucide_icons.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../../core/theme/theme_provider.dart';

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
                    title: const Text('Encrypted Backup'),
                    subtitle: const Text('Last backed up yesterday'),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () {},
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
