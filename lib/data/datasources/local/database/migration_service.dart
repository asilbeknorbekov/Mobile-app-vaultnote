import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';

class MigrationService {
  final SharedPreferences _prefs;
  final AppDatabase _db;

  MigrationService(this._prefs, this._db);

  Future<void> migrateFromSharedPreferences() async {
    final rawNotes = _prefs.getString('vault_notes');
    if (rawNotes != null) {
      final list = jsonDecode(rawNotes) as List;
      final oldNotes = list.cast<Map<String, dynamic>>();

      await _db.transaction(() async {
        for (var n in oldNotes) {
          final id = n['id'] as String;
          final title = n['title'] as String;
          final body = n['body'] as String;
          final createdAt = DateTime.parse(n['createdAt'] as String);
          final updatedAt = DateTime.parse(n['updatedAt'] as String);
          
          await _db.into(_db.notes).insert(
            NotesCompanion.insert(
              id: id,
              title: title,
              body: body,
              createdAt: createdAt,
              updatedAt: updatedAt,
              isEncrypted: const Value(false),
            ),
            mode: InsertMode.insertOrIgnore,
          );

          if (n['tags'] != null) {
            final tags = (n['tags'] as List).cast<String>();
            for (var tag in tags) {
              await _db.into(_db.tags).insert(
                TagsCompanion.insert(id: tag, name: tag),
                mode: InsertMode.insertOrIgnore,
              );
              await _db.into(_db.noteTags).insert(
                NoteTagsCompanion.insert(noteId: id, tagId: tag),
                mode: InsertMode.insertOrIgnore,
              );
            }
          }
        }
      });
      await _prefs.remove('vault_notes');
    }

    final rawFiles = _prefs.getString('vault_files');
    if (rawFiles != null) {
      final list = jsonDecode(rawFiles) as List;
      final oldFiles = list.cast<Map<String, dynamic>>();

      await _db.transaction(() async {
        for (var f in oldFiles) {
          final id = f['id'] as String;
          final noteId = f['noteId'] as String?;
          final fileName = f['fileName'] as String;
          final fileType = f['fileType'] as String;
          final localPath = f['localPath'] as String;
          final sizeBytes = f['sizeBytes'] as int;
          final createdAt = DateTime.parse(f['createdAt'] as String);

          await _db.into(_db.vaultFiles).insert(
            VaultFilesCompanion.insert(
              id: id,
              noteId: Value(noteId),
              fileName: fileName,
              fileType: fileType,
              localPath: localPath,
              sizeBytes: sizeBytes,
              createdAt: createdAt,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
      await _prefs.remove('vault_files');
    }
  }
}
