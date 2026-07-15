import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/notes_repository.dart';
import '../datasources/local/daos/notes_dao.dart';
import '../../../core/security/encryption_service.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesDao _dao;
  final EncryptionService _encryption;

  NotesRepositoryImpl(SharedPreferences prefs)
      : _dao = NotesDao(prefs),
        _encryption = EncryptionService();

  @override
  Future<List<Note>> getAllNotes() async {
    final rows = _dao.getAllNotes();
    return rows.map((r) => Note(
      id: r['id'] as String,
      title: r['title'] as String,
      content: _encryption.decryptString(r['content'] as String),
      tags: (r['tags'] as List?)?.cast<String>() ?? [],
      isPinned: r['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(r['createdAt'] as String),
      updatedAt: DateTime.parse(r['updatedAt'] as String),
    )).toList();
  }

  @override
  Future<void> saveNote(Note note) async {
    await _dao.insertNote({
      'id': note.id,
      'title': note.title,
      'content': _encryption.encryptString(note.content),
      'tags': note.tags,
      'isPinned': note.isPinned,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteNote(String id) async {
    await _dao.deleteNote(id);
  }
}
