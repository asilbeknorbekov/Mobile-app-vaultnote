import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FilesDao {
  final SharedPreferences _prefs;
  static const _key = 'vault_files';

  FilesDao(this._prefs);

  List<Map<String, dynamic>> getAllFiles() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic>? getFileById(String id) {
    final files = getAllFiles();
    try {
      return files.firstWhere((f) => f['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> insertFile(Map<String, dynamic> file) async {
    final files = getAllFiles();
    files.insert(0, file);
    await _prefs.setString(_key, jsonEncode(files));
  }

  Future<void> deleteFile(String id) async {
    final files = getAllFiles();
    files.removeWhere((f) => f['id'] == id);
    await _prefs.setString(_key, jsonEncode(files));
  }
}
