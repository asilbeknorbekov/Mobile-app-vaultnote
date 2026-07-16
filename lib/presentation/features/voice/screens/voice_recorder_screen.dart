import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';

class VoiceRecorderScreen extends ConsumerStatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  ConsumerState<VoiceRecorderScreen> createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends ConsumerState<VoiceRecorderScreen> {
  bool _isRecording = false;
  
  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // TODO: Connect to actual audio recording plugin
  }

  void _saveRecording() {
    // TODO: Finalize recording, encrypt bytes, save via FilesProvider
    context.pop();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isRecording ? '00:14' : 'Ready to record',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Placeholder for audio waveform visualization
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _isRecording ? '|||||||||||||||||||||||||||' : '—',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_isRecording)
                          IconButton(
                            iconSize: 32,
                            icon: const Icon(LucideIcons.x, color: Colors.red),
                            onPressed: () {
                              setState(() => _isRecording = false);
                              context.pop();
                            },
                          )
                        else
                          const SizedBox(width: 48), // spacer
                          
                        GestureDetector(
                          onTap: _toggleRecording,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording ? Colors.red : Theme.of(context).colorScheme.primary).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                )
                              ],
                            ),
                            child: Icon(
                              _isRecording ? LucideIcons.square : LucideIcons.mic,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),

                        if (_isRecording)
                          IconButton(
                            iconSize: 32,
                            icon: const Icon(LucideIcons.check, color: Colors.green),
                            onPressed: _saveRecording,
                          )
                        else
                          const SizedBox(width: 48), // spacer
                      ],
                    ),
                  ],
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
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Voice Note',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
