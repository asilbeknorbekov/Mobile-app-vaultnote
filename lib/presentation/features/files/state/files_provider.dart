import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/vault_file.dart';
import '../../../../domain/repositories/files_repository.dart';
import '../../../../data/repositories_impl/files_repository_impl.dart';
import '../../../app.dart';

final filesProvider = AsyncNotifierProvider<FilesNotifier, List<VaultFile>>(() {
  return FilesNotifier();
});

class FilesNotifier extends AsyncNotifier<List<VaultFile>> {
  late final FilesRepository _repository;

  @override
  Future<List<VaultFile>> build() async {
    final prefs = ref.watch(sharedPrefsProvider);
    _repository = FilesRepositoryImpl(prefs);
    return _repository.getAllFiles();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllFiles());
  }

  Future<VaultFile?> saveFile(String fileName, String fileType, Uint8List bytes, {String? noteId}) async {
    try {
      final newFile = await _repository.saveFile(
        fileName: fileName, fileType: fileType, rawBytes: bytes, noteId: noteId,
      );
      if (state.hasValue) {
        final list = List<VaultFile>.from(state.value!);
        list.insert(0, newFile);
        state = AsyncValue.data(list);
      }
      return newFile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _repository.deleteFile(fileId);
      if (state.hasValue) {
        final list = List<VaultFile>.from(state.value!);
        list.removeWhere((f) => f.id == fileId);
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
