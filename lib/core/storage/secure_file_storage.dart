import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../security/encryption_service.dart';

class SecureFileStorage {
  final EncryptionService _encryptionService = EncryptionService();

  Future<Directory> _getVaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(p.join(appDir.path, 'vault_files'));
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  Future<String> saveFile(String fileId, Uint8List rawBytes, String extension) async {
    final vaultDir = await _getVaultDirectory();
    final file = File(p.join(vaultDir.path, '$fileId.$extension.enc'));
    final encryptedBytes = _encryptionService.encryptBytes(rawBytes);
    await file.writeAsBytes(encryptedBytes, flush: true);
    return file.path;
  }

  Future<Uint8List> readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const FileSystemException('Encrypted file not found');
    }
    final encryptedBytes = await file.readAsBytes();
    return _encryptionService.decryptBytes(encryptedBytes);
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
