import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_service.dart';
import 'encryption_service.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  final securityService = ref.watch(securityServiceProvider);
  return EncryptionService(securityService);
});
