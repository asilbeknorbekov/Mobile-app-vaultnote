import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotesDao {
  final SharedPreferences _prefs;
  static const _key = 'vault_notes';

  NotesDao(this._prefs);

  List<Map<String, dynamic>> getAllNotes() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> insertNote(Map<String, dynamic> note) async {
    final notes = getAllNotes();
    final idx = notes.indexWhere((n) => n['id'] == note['id']);
    if (idx >= 0) {
      notes[idx] = note;
    } else {
      notes.insert(0, note);
    }
    await _prefs.setString(_key, jsonEncode(notes));
  }

  Future<void> deleteNote(String id) async {
    final notes = getAllNotes();
    notes.removeWhere((n) => n['id'] == id);
    await _prefs.setString(_key, jsonEncode(notes));
  }
}
