import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../core/storage/secure_file_storage.dart';
import '../../../domain/entities/vault_file.dart';
import '../../../domain/repositories/files_repository.dart';
import '../datasources/local/database/app_database.dart';

class FilesRepositoryImpl implements FilesRepository {
  final AppDatabase _db;
  final SecureFileStorage _storage;

  FilesRepositoryImpl(this._db, this._storage);

  @override
  Future<List<VaultFile>> getAllFiles() async {
    final rows = await _db.select(_db.vaultFiles).get();
    return rows.map((r) => VaultFile(
      id: r.id,
      noteId: r.noteId,
      fileName: r.fileName,
      fileType: r.fileType,
      localPath: r.localPath,
      sizeBytes: r.sizeBytes,
      createdAt: r.createdAt,
    )).toList();
  }

  @override
  Future<List<VaultFile>> getFilesForNote(String noteId) async {
    final query = _db.select(_db.vaultFiles)..where((t) => t.noteId.equals(noteId));
    final rows = await query.get();
    return rows.map((r) => VaultFile(
      id: r.id,
      noteId: r.noteId,
      fileName: r.fileName,
      fileType: r.fileType,
      localPath: r.localPath,
      sizeBytes: r.sizeBytes,
      createdAt: r.createdAt,
    )).toList();
  }

  @override
  Future<VaultFile> saveFile({
    required String fileName,
    required String fileType,
    required Uint8List rawBytes,
    String? noteId,
  }) async {
    final fileId = const Uuid().v4();
    final localPath = await _storage.saveFile(fileId, rawBytes, fileType);
    final createdAt = DateTime.now();

    await _db.into(_db.vaultFiles).insert(
      VaultFilesCompanion.insert(
        id: fileId,
        noteId: Value(noteId),
        fileName: fileName,
        fileType: fileType,
        localPath: localPath,
        sizeBytes: rawBytes.length,
        createdAt: createdAt,
      ),
    );

    return VaultFile(
      id: fileId, noteId: noteId, fileName: fileName,
      fileType: fileType, localPath: localPath,
      sizeBytes: rawBytes.length, createdAt: createdAt,
    );
  }

  @override
  Future<Uint8List> getFileBytes(String fileId) async {
    final query = _db.select(_db.vaultFiles)..where((t) => t.id.equals(fileId));
    final file = await query.getSingleOrNull();
    if (file == null) throw Exception('File not found');
    return await _storage.readFile(file.localPath);
  }

  @override
  Future<void> deleteFile(String fileId) async {
    final query = _db.select(_db.vaultFiles)..where((t) => t.id.equals(fileId));
    final file = await query.getSingleOrNull();
    if (file != null) {
      await _storage.deleteFile(file.localPath);
      await (_db.delete(_db.vaultFiles)..where((t) => t.id.equals(fileId))).go();
    }
  }
}
