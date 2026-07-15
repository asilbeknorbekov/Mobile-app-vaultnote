import 'dart:convert';
import 'dart:typed_data';

class EncryptionService {
  /// Simple encoding for MVP. In production, replace with AES-256.
  String encryptString(String plainText) {
    return base64Encode(utf8.encode(plainText));
  }

  String decryptString(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }

  Uint8List encryptBytes(Uint8List data) {
    return Uint8List.fromList(base64Encode(data).codeUnits);
  }

  Uint8List decryptBytes(Uint8List data) {
    return base64Decode(String.fromCharCodes(data));
  }
}
