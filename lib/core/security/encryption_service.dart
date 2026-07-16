import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'security_service.dart';

class EncryptionService {
  final SecurityService _securityService;

  EncryptionService(this._securityService);

  /// Encrypts bytes using AES-256 GCM
  Uint8List encryptBytes(Uint8List data) {
    final keyBytes = _securityService.activeKey;
    if (keyBytes == null) throw Exception("Vault is locked");

    final key = enc.Key(keyBytes);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = encrypter.encryptBytes(data, iv: iv);
    
    // Prepend the IV to the encrypted data so we can decrypt it later
    final builder = BytesBuilder();
    builder.add(iv.bytes);
    builder.add(encrypted.bytes);
    return builder.toBytes();
  }

  /// Decrypts bytes using AES-256 GCM
  Uint8List decryptBytes(Uint8List encryptedData) {
    final keyBytes = _securityService.activeKey;
    if (keyBytes == null) throw Exception("Vault is locked");

    if (encryptedData.length < 16) throw Exception("Invalid encrypted data");

    final key = enc.Key(keyBytes);
    final iv = enc.IV(encryptedData.sublist(0, 16));
    final ciphertext = encryptedData.sublist(16);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    
    final encrypted = enc.Encrypted(ciphertext);
    return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
  }
}
