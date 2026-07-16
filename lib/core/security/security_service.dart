import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:local_auth/local_auth.dart';
import 'package:encrypt/encrypt.dart' as enc;

class SecurityService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();
  
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _vaultKeyKey = 'vault_key';
  
  /// Holds the AES key in memory only while the app is unlocked.
  Uint8List? _activeVaultKey;
  
  bool get isUnlocked => _activeVaultKey != null;
  Uint8List? get activeKey => _activeVaultKey;

  void lock() {
    _activeVaultKey = null;
  }

  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null;
  }

  Future<void> setPin(String pin) async {
    // 1. Generate a salt
    final random = Random.secure();
    final salt = List<int>.generate(16, (i) => random.nextInt(256));
    
    // 2. Hash the PIN using PBKDF2
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final secretKey = SecretKey(utf8.encode(pin));
    final mac = await pbkdf2.deriveKey(secretKey: secretKey, nonce: salt);
    final hashBytes = await mac.extractBytes();
    
    // 3. Generate a strong random AES-256 key for the vault
    final vaultKeyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    
    // 4. Store everything securely
    await _storage.write(key: _pinSaltKey, value: base64Encode(salt));
    await _storage.write(key: _pinHashKey, value: base64Encode(hashBytes));
    await _storage.write(key: _vaultKeyKey, value: base64Encode(vaultKeyBytes));
    
    _activeVaultKey = Uint8List.fromList(vaultKeyBytes);
  }

  Future<bool> verifyPin(String pin) async {
    final storedSalt = await _storage.read(key: _pinSaltKey);
    final storedHash = await _storage.read(key: _pinHashKey);
    
    if (storedSalt == null || storedHash == null) return false;
    
    final salt = base64Decode(storedSalt);
    
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final secretKey = SecretKey(utf8.encode(pin));
    final mac = await pbkdf2.deriveKey(secretKey: secretKey, nonce: salt);
    final hashBytes = await mac.extractBytes();
    
    if (base64Encode(hashBytes) == storedHash) {
      // PIN matches, retrieve the vault key into memory
      final storedVaultKey = await _storage.read(key: _vaultKeyKey);
      if (storedVaultKey != null) {
        _activeVaultKey = Uint8List.fromList(base64Decode(storedVaultKey));
      }
      return true;
    }
    return false;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      
      if (!canAuthenticate) return false;

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock your vault',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
         final storedVaultKey = await _storage.read(key: _vaultKeyKey);
         if (storedVaultKey != null) {
           _activeVaultKey = Uint8List.fromList(base64Decode(storedVaultKey));
           return true;
         }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
