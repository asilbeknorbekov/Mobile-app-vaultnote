import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getAllNotes();
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
}
