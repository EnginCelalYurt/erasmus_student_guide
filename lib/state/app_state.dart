import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/guide_topic.dart';

class AppState extends ChangeNotifier {
  static const _prefsKey = 'uniguide_v2_prefs';

  List<SurvivalTip> tips = SampleData.survivalTips();

  final Set<String> _savedTipIds = {};

  ThemeMode themeMode = ThemeMode.system;
  String notes = '';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      notifyListeners();
      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final tipIds = (data['savedTipIds'] as List?)?.cast<String>() ?? [];
      final theme = data['theme'] as String?;
      notes = data['notes'] as String? ?? '';

      _savedTipIds
        ..clear()
        ..addAll(tipIds);

      themeMode = switch (theme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    } catch (_) {
      notes = '';
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'savedTipIds': _savedTipIds.toList(),
        'notes': notes,
        'theme': switch (themeMode) {
          ThemeMode.dark => 'dark',
          ThemeMode.light => 'light',
          ThemeMode.system => 'system',
        },
      }),
    );
  }

  // Saved queries
  bool isTipSaved(String id) => _savedTipIds.contains(id);

  List<SurvivalTip> get savedTips =>
      tips.where((tip) => _savedTipIds.contains(tip.id)).toList();

  int get totalSavedCount => _savedTipIds.length;

  // Actions
  void toggleSaveTip(String id) {
    if (_savedTipIds.contains(id)) {
      _savedTipIds.remove(id);
    } else {
      _savedTipIds.add(id);
    }
    notifyListeners();
    _persist();
  }

  void setNotes(String value) {
    notes = value;
    _persist();
  }

  void cycleTheme() {
    themeMode = switch (themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    notifyListeners();
    _persist();
  }
}
