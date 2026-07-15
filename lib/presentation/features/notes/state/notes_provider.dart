import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/entities/note.dart';
import '../../../../domain/repositories/notes_repository.dart';
import '../../../../data/repositories_impl/notes_repository_impl.dart';
import '../../../app.dart';

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late final NotesRepository _repository;

  @override
  Future<List<Note>> build() async {
    final prefs = ref.watch(sharedPrefsProvider);
    _repository = NotesRepositoryImpl(prefs);
    return _repository.getAllNotes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllNotes());
  }

  Future<void> saveNote(Note note) async {
    await _repository.saveNote(note);
    if (state.hasValue) {
      final list = List<Note>.from(state.value!);
      final idx = list.indexWhere((n) => n.id == note.id);
      if (idx >= 0) {
        list[idx] = note;
      } else {
        list.insert(0, note);
      }
      state = AsyncValue.data(list);
    }
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    if (state.hasValue) {
      final list = List<Note>.from(state.value!);
      list.removeWhere((n) => n.id == id);
      state = AsyncValue.data(list);
    }
  }
}
