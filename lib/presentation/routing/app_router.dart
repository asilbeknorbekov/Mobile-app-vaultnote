import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/note.dart';
import '../features/main/main_scaffold.dart';
import '../features/home/screens/home_screen.dart';
import '../features/notes/screens/notes_list_screen.dart';
import '../features/notes/screens/note_editor_screen.dart';
import '../app.dart';
import '../features/files/screens/files_list_screen.dart';
import '../features/files/screens/pin_auth_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/voice/screens/voice_recorder_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionANavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionANav');
final _sectionBNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionBNav');
final _sectionCNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionCNav');
final _sectionDNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionDNav');

final goRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: hasCompletedOnboarding ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PinAuthScreen(child: MainScaffold(navigationShell: navigationShell));
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _sectionANavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'voice',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      final mode = extra?['mode'] as String? ?? 'audio';
                      return VoiceRecorderScreen(mode: mode);
                    },
                  ),
                  GoRoute(
                    path: 'search',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const SearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Notes
          StatefulShellBranch(
            navigatorKey: _sectionBNavigatorKey,
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NotesListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav when creating a note
                    builder: (context, state) => const NoteEditorScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav when editing a note
                    builder: (context, state) {
                      final existingNote = state.extra as Note?;
                      return NoteEditorScreen(existingNote: existingNote);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Files
          StatefulShellBranch(
            navigatorKey: _sectionCNavigatorKey,
            routes: [
              GoRoute(
                path: '/files',
                builder: (context, state) => const FilesListScreen(),
              ),
            ],
          ),
          // Branch 3: Settings
          StatefulShellBranch(
            navigatorKey: _sectionDNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
