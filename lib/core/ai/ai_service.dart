import '../../domain/entities/note.dart';

class AiService {
  
  /// Simulates querying the AI with context from the local vault.
  /// Yields strings to simulate a streaming response.
  Stream<String> askAssistant(String query, List<Note> vaultContext) async* {
    // Artificial network/processing delay
    await Future.delayed(const Duration(milliseconds: 600));

    final lowerQuery = query.toLowerCase();
    
    // Simple mock logic for Phase 1 MVP
    String response;
    if (lowerQuery.contains('hello') || lowerQuery.contains('hi')) {
      response = "Hello! I am your VaultNote Second Brain. I can answer questions based on the notes and files you've saved. What would you like to know?";
    } else if (vaultContext.isEmpty) {
      response = "I searched your vault, but it looks like you haven't saved any notes yet! Try creating a note first, then ask me about it.";
    } else {
      // Find a matching note based on a simple keyword match
      final matchedNotes = vaultContext.where((n) => 
        n.title.toLowerCase().contains(lowerQuery) || 
        n.content.toLowerCase().contains(lowerQuery)
      ).toList();

      if (matchedNotes.isNotEmpty) {
        response = "Based on your note **${matchedNotes.first.title}**, here is what I found:\n\n${matchedNotes.first.content}\n\n*Source: ${matchedNotes.first.title}*";
      } else {
        response = "I looked through your ${vaultContext.length} notes, but I couldn't find anything specifically answering that question.";
      }
    }

    // Simulate streaming word by word
    final words = response.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield '${words[i]} ';
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}
