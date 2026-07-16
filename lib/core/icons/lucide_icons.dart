/// Compatibility layer: maps LucideIcons names to Flutter Material Icons.
/// This allows all screens to keep using `LucideIcons.xxx` syntax
/// while using the built-in Material icon set.
library;

import 'package:flutter/material.dart';

class LucideIcons {
  LucideIcons._();

  // Navigation & UI
  static const IconData home = Icons.home_outlined;
  static const IconData fileText = Icons.description_outlined;
  static const IconData folder = Icons.folder_outlined;
  static const IconData folderOpen = Icons.folder_open_outlined;
  static const IconData sparkles = Icons.auto_awesome_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData search = Icons.search;
  static const IconData plus = Icons.add;
  static const IconData chevronLeft = Icons.chevron_left;
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData arrowLeft = Icons.arrow_back;
  static const IconData moreVertical = Icons.more_vert;
  static const IconData x = Icons.close;
  static const IconData check = Icons.check;

  // Notes & Files
  static const IconData penTool = Icons.edit_outlined;
  static const IconData bookOpen = Icons.menu_book_outlined;
  static const IconData pin = Icons.push_pin_outlined;
  static const IconData pinOff = Icons.push_pin;
  static const IconData file = Icons.insert_drive_file_outlined;
  static const IconData image = Icons.image_outlined;
  static const IconData music = Icons.music_note_outlined;
  static const IconData trash2 = Icons.delete_outlined;

  // Media
  static const IconData mic = Icons.mic_outlined;
  static const IconData micOff = Icons.mic_off_outlined;
  static const IconData scan = Icons.document_scanner_outlined;
  static const IconData send = Icons.send;
  static const IconData square = Icons.stop;
  static const IconData play = Icons.play_arrow_outlined;

  // Dashboard & Stats
  static const IconData database = Icons.storage_outlined;
  static const IconData zap = Icons.flash_on_outlined;
  static const IconData cpu = Icons.memory_outlined;

  // Security & Settings
  static const IconData lock = Icons.lock_outlined;
  static const IconData fingerprint = Icons.fingerprint;
  static const IconData moon = Icons.dark_mode_outlined;
  static const IconData eyeOff = Icons.visibility_off_outlined;
  static const IconData downloadCloud = Icons.cloud_download_outlined;
  static const IconData logOut = Icons.logout_outlined;

  // Onboarding
  static const IconData brainCircuit = Icons.psychology_outlined;
  static const IconData user = Icons.person_outline;
}
