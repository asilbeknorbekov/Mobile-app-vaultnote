import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/vault_file.dart';
import '../../../../domain/repositories/files_repository.dart';
import '../../../../data/repositories_impl/files_repository_impl.dart';
import '../../../../data/datasources/local/database/database_provider.dart';
import '../../../../core/storage/secure_file_storage.dart';
import '../../../../core/security/security_provider.dart';

final filesProvider = StreamProvider<List<VaultFile>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.vaultFiles).watch().map((rows) {
    return rows.map((r) => VaultFile(
      id: r.id,
      noteId: r.noteId,
      fileName: r.fileName,
      fileType: r.fileType,
      localPath: r.localPath,
      sizeBytes: r.sizeBytes,
      createdAt: r.createdAt,
    )).toList();
  });
});

final filesNotifierProvider = Provider<FilesNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  final storage = SecureFileStorage(encryptionService);
  final repo = FilesRepositoryImpl(db, storage);
  return FilesNotifier(repo);
});

class FilesNotifier {
  final FilesRepository _repository;

  FilesNotifier(this._repository);

  Future<VaultFile?> saveFile(String fileName, String fileType, Uint8List bytes, {String? noteId}) async {
    try {
      return await _repository.saveFile(
        fileName: fileName, fileType: fileType, rawBytes: bytes, noteId: noteId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteFile(String fileId) async {
    await _repository.deleteFile(fileId);
  }
}
