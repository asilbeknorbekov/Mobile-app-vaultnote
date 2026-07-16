import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../domain/entities/note.dart';
import '../../notes/state/notes_provider.dart';
import '../../files/state/files_provider.dart';
import 'dart:io';

class VoiceRecorderScreen extends ConsumerStatefulWidget {
  final String mode; // 'audio' or 'transcribe'
  
  const VoiceRecorderScreen({super.key, required this.mode});

  @override
  ConsumerState<VoiceRecorderScreen> createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends ConsumerState<VoiceRecorderScreen> {
  late RecorderController _recorderController;
  late stt.SpeechToText _speechToText;
  
  bool _isRecording = false;
  String _transcribedText = "";
  
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
      
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorderController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')} : ${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorderController.checkPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission required')));
      }
      return;
    }

    if (widget.mode == 'transcribe') {
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(onResult: (result) {
          if (result.finalResult) {
            _transcribedText = result.recognizedWords;
          }
        });
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    
    await _recorderController.record(path: path);
    _startTimer();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorderController.stop();
    _stopTimer();
    
    if (widget.mode == 'transcribe') {
      await _speechToText.stop();
    }
    
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      if (widget.mode == 'audio') {
        final bytes = await File(path).readAsBytes();
        await ref.read(filesNotifierProvider).saveFile('Voice_Note_${DateTime.now().millisecondsSinceEpoch}.m4a', 'm4a', bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio saved to Vault')));
          context.pop();
        }
      } else {
        // Transcribe mode: we save the text as a note
        if (_transcribedText.isNotEmpty) {
           final newNote = Note(
              id: const Uuid().v4(),
              title: 'Voice Note',
              content: _transcribedText,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              tags: [],
            );
            ref.read(notesNotifierProvider).saveNote(newNote);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transcribed note saved')));
              context.pop();
            }
        } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not transcribe audio.')));
              context.pop();
            }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark moody background
      body: Stack(
        children: [
          // Background Gradient / Image could go here, for now it's dark
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                radius: 1.5,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isRecording ? 'Recording...' : 'Ready to record',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 64),
                      
                      // The Waveform
                      SizedBox(
                        height: 100,
                        child: AudioWaveforms(
                          enableGesture: false,
                          size: Size(MediaQuery.of(context).size.width, 100),
                          recorderController: _recorderController,
                          waveStyle: const WaveStyle(
                            waveColor: Color(0xFF00E5FF), // Neon Blue
                            extendWaveform: true,
                            showMiddleLine: false,
                            waveThickness: 4,
                            spacing: 8,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 64),
                      
                      // Timer Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Text(
                          _formatTime(_seconds),
                          style: const TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 80),
                      
                      // Bottom Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSmallButton(LucideIcons.pin, () {}),
                          const SizedBox(width: 32),
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: Icon(
                                _isRecording ? LucideIcons.micOff : LucideIcons.mic,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          _buildSmallButton(LucideIcons.play, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
