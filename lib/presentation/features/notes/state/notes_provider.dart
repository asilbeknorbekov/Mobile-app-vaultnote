import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/note.dart';
import '../../../../data/datasources/local/database/app_database.dart';
import '../../../../data/datasources/local/database/database_provider.dart';
import 'package:drift/drift.dart';

final notesProvider = StreamProvider<List<Note>>((ref) {
  final db = ref.watch(databaseProvider);
  
  return db.select(db.notes).watch().map((rows) {
    return rows.map((r) => Note(
      id: r.id,
      title: r.title,
      content: r.body,
      tags: [], // Tags will be queried separately if needed
      isPinned: false, // Drift schema doesn't have isPinned right now, maybe add it later
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  });
});

final notesNotifierProvider = Provider<NotesNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesNotifier(db);
});

class NotesNotifier {
  final AppDatabase _db;

  NotesNotifier(this._db);

  Future<void> saveNote(Note note) async {
    await _db.into(_db.notes).insert(
      NotesCompanion.insert(
        id: note.id,
        title: note.title,
        body: note.content,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
        isEncrypted: const Value(false),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteNote(String id) async {
    await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }
}
