import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

@DataClassName('NoteEntry')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagEntry')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NoteTagEntry')
class NoteTags extends Table {
  TextColumn get noteId => text().references(Notes, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

@DataClassName('VaultFileEntry')
class VaultFiles extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().nullable().references(Notes, #id)();
  TextColumn get fileName => text()();
  TextColumn get fileType => text()();
  TextColumn get localPath => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Notes, Tags, NoteTags, VaultFiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      
      // Create FTS5 virtual table
      await customStatement('''
        CREATE VIRTUAL TABLE notes_fts USING fts5(
          title, 
          body, 
          content=notes, 
          content_rowid=rowid
        );
      ''');

      // Create triggers to keep FTS table in sync
      await customStatement('''
        CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
          INSERT INTO notes_fts(rowid, title, body) VALUES (new.rowid, new.title, new.body);
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER notes_ad AFTER DELETE ON notes BEGIN
          INSERT INTO notes_fts(notes_fts, rowid, title, body) VALUES ('delete', old.rowid, old.title, old.body);
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER notes_au AFTER UPDATE ON notes BEGIN
          INSERT INTO notes_fts(notes_fts, rowid, title, body) VALUES ('delete', old.rowid, old.title, old.body);
          INSERT INTO notes_fts(rowid, title, body) VALUES (new.rowid, new.title, new.body);
        END;
      ''');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<List<NoteEntry>> searchNotes(String query) async {
    // If the query is empty, return all notes
    if (query.trim().isEmpty) {
      return select(notes).get();
    }
    
    // Append a wildcard to allow prefix matching
    final ftsQuery = "${query.replaceAll('\'', '\'\'')}*";
    
    final result = await customSelect('''
      SELECT notes.* FROM notes
      JOIN notes_fts ON notes.rowid = notes_fts.rowid
      WHERE notes_fts MATCH ?
      ORDER BY rank
    ''', variables: [Variable.withString(ftsQuery)], readsFrom: {notes}).get();
    
    return result.map(notes.mapFromRow).toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vaultnote_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
