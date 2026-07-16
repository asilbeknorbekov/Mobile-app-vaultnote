import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import '../../../../core/design_system/glass_surface.dart';
import '../../../../core/design_system/glass_theme.dart';
import '../../notes/state/notes_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage(this.text, this.isUser);
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage("Hi! I'm your offline local Assistant. Ask me to search your notes for a keyword.", false),
  ];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _isTyping = true;
    });

    // Simulate a brief "thinking" pause
    await Future.delayed(const Duration(milliseconds: 500));

    // Fetch notes context for the local AI
    final notes = ref.read(notesProvider).valueOrNull ?? [];
    final query = text.toLowerCase();
    final matchingNotes = notes.where((n) => 
        n.title.toLowerCase().contains(query) || 
        n.content.toLowerCase().contains(query)
    ).toList();

    String response;
    if (matchingNotes.isEmpty) {
      response = "I couldn't find any notes mentioning '$text'.";
    } else {
      response = "I found ${matchingNotes.length} notes about '$text':\n";
      for (var n in matchingNotes) {
        response += "• ${n.title.isNotEmpty ? n.title : 'Untitled'}\n";
      }
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(response, false));
      _isTyping = false;
    });
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _ChatBubble(message: msg);
                  },
                ),
              ),
              _buildInputArea(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return GlassSurface(
      tier: GlassTier.tier1,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.all(16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Assistant',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Icon(LucideIcons.sparkles, color: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Padding(
      // Extra bottom padding to avoid bottom nav bar
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100, top: 8),
      child: GlassSurface(
        tier: GlassTier.tier2,
        borderRadius: BorderRadius.circular(32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Ask your second brain...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.send,
                color: _isTyping ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
              onPressed: _isTyping ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser 
        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
        : Colors.transparent;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: GlassSurface(
          tier: message.isUser ? GlassTier.tier3 : GlassTier.tier2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
          child: Text(
            message.text,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
      ),
    );
  }
}
