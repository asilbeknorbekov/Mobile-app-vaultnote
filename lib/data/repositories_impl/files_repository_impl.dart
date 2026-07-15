import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/secure_file_storage.dart';
import '../../../domain/entities/vault_file.dart';
import '../../../domain/repositories/files_repository.dart';
import '../datasources/local/daos/files_dao.dart';

class FilesRepositoryImpl implements FilesRepository {
  final FilesDao _dao;
  final SecureFileStorage _storage;

  FilesRepositoryImpl(SharedPreferences prefs)
      : _dao = FilesDao(prefs),
        _storage = SecureFileStorage();

  @override
  Future<List<VaultFile>> getAllFiles() async {
    final rows = _dao.getAllFiles();
    return rows.map((r) => VaultFile(
      id: r['id'] as String,
      noteId: r['noteId'] as String?,
      fileName: r['fileName'] as String,
      fileType: r['fileType'] as String,
      localPath: r['localPath'] as String,
      sizeBytes: r['sizeBytes'] as int,
      createdAt: DateTime.parse(r['createdAt'] as String),
    )).toList();
  }

  @override
  Future<List<VaultFile>> getFilesForNote(String noteId) async {
    final all = await getAllFiles();
    return all.where((f) => f.noteId == noteId).toList();
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

    await _dao.insertFile({
      'id': fileId,
      'noteId': noteId,
      'fileName': fileName,
      'fileType': fileType,
      'localPath': localPath,
      'sizeBytes': rawBytes.length,
      'createdAt': createdAt.toIso8601String(),
    });

    return VaultFile(
      id: fileId, noteId: noteId, fileName: fileName,
      fileType: fileType, localPath: localPath,
      sizeBytes: rawBytes.length, createdAt: createdAt,
    );
  }

  @override
  Future<Uint8List> getFileBytes(String fileId) async {
    final file = _dao.getFileById(fileId);
    if (file == null) throw Exception('File not found');
    return await _storage.readFile(file['localPath'] as String);
  }

  @override
  Future<void> deleteFile(String fileId) async {
    final file = _dao.getFileById(fileId);
    if (file != null) {
      await _storage.deleteFile(file['localPath'] as String);
      await _dao.deleteFile(fileId);
    }
  }
}
