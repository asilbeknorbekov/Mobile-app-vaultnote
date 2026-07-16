import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class BackupService {
  
  /// Exports the entire database and vault files as an encrypted ZIP file.
  Future<void> exportVault(String password) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(appDir.path, 'vaultnote_db.sqlite'));
    final vaultDir = Directory(p.join(appDir.path, 'vault_files'));

    // Create a temporary unencrypted zip
    final tempDir = await getTemporaryDirectory();
    final zipFile = File(p.join(tempDir.path, 'vault_export.zip'));
    
    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path);
    
    if (await dbFile.exists()) {
      encoder.addFile(dbFile);
    }
    
    if (await vaultDir.exists()) {
      encoder.addDirectory(vaultDir);
    }
    
    encoder.close();

    // Encrypt the zip file with AES-256 derived from the password
    final keyBytes = _deriveKeyFromPassword(password);
    final key = enc.Key(keyBytes);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final zipBytes = await zipFile.readAsBytes();
    final encrypted = encrypter.encryptBytes(zipBytes, iv: iv);

    final encryptedFile = File(p.join(tempDir.path, 'anote_backup.enc'));
    final builder = BytesBuilder();
    builder.add(iv.bytes);
    builder.add(encrypted.bytes);
    await encryptedFile.writeAsBytes(builder.toBytes(), flush: true);

    // Share the encrypted file
    await Share.shareXFiles([XFile(encryptedFile.path)], text: 'ANOTE Vault Backup');
    
    // Cleanup temp files
    await zipFile.delete();
  }

  /// Imports an encrypted ZIP file and replaces the current database and vault.
  Future<void> importVault(String filePath, String password) async {
    final encryptedFile = File(filePath);
    if (!await encryptedFile.exists()) throw Exception("File not found");

    final encryptedData = await encryptedFile.readAsBytes();
    if (encryptedData.length < 16) throw Exception("Invalid backup file");

    final keyBytes = _deriveKeyFromPassword(password);
    final key = enc.Key(keyBytes);
    final iv = enc.IV(encryptedData.sublist(0, 16));
    final ciphertext = encryptedData.sublist(16);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    
    Uint8List decryptedZipBytes;
    try {
      final encrypted = enc.Encrypted(ciphertext);
      decryptedZipBytes = Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (e) {
      throw Exception("Incorrect password or corrupted backup");
    }

    final tempDir = await getTemporaryDirectory();
    final extractedDir = Directory(p.join(tempDir.path, 'extracted_vault'));
    if (await extractedDir.exists()) {
      await extractedDir.delete(recursive: true);
    }
    
    final archive = ZipDecoder().decodeBytes(decryptedZipBytes);
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(p.join(extractedDir.path, filename));
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory(p.join(extractedDir.path, filename)).create(recursive: true);
      }
    }

    // Now overwrite the local app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    
    // Replace DB
    final importedDbFile = File(p.join(extractedDir.path, 'vaultnote_db.sqlite'));
    if (await importedDbFile.exists()) {
      final localDbFile = File(p.join(appDir.path, 'vaultnote_db.sqlite'));
      if (await localDbFile.exists()) await localDbFile.delete();
      await importedDbFile.copy(localDbFile.path);
    }

    // Replace Vault Files
    final importedVaultDir = Directory(p.join(extractedDir.path, 'vault_files'));
    final localVaultDir = Directory(p.join(appDir.path, 'vault_files'));
    if (await localVaultDir.exists()) {
      await localVaultDir.delete(recursive: true);
    }
    
    if (await importedVaultDir.exists()) {
      await _copyDirectory(importedVaultDir, localVaultDir);
    }

    // Cleanup
    await extractedDir.delete(recursive: true);
  }

  Uint8List _deriveKeyFromPassword(String password) {
    // Basic SHA-256 derivation. 
    // Since the user creates the password on export and inputs it on import,
    // we don't store a salt. We just hash the password string to 32 bytes.
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory(p.join(destination.path, p.basename(entity.path)));
        await newDirectory.create();
        await _copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }
}
