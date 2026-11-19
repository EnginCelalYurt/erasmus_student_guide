import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/guide_topic.dart';
import '../models/university.dart';

class AppState extends ChangeNotifier {
  static const _prefsKey = 'uniguide_v2_prefs';

  UniversityProfile university = SampleData.universityProfile();
  List<SurvivalTip> tips = SampleData.survivalTips();
  List<CityPlace> places = SampleData.places();
  List<ChecklistItem> checklist = SampleData.checklist();

  final Set<String> _savedTipIds = {};
  final Set<String> _savedPlaceIds = {};
  final Set<String> _savedFacilityIds = {};

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
      final placeIds = (data['savedPlaceIds'] as List?)?.cast<String>() ?? [];
      final facilityIds = (data['savedFacilityIds'] as List?)?.cast<String>() ?? [];
      final doneIds = (data['doneIds'] as List?)?.cast<String>() ?? [];
      final theme = data['theme'] as String?;
      notes = data['notes'] as String? ?? '';

      _savedTipIds
        ..clear()
        ..addAll(tipIds);
      _savedPlaceIds
        ..clear()
        ..addAll(placeIds);
      _savedFacilityIds
        ..clear()
        ..addAll(facilityIds);

      for (final item in checklist) {
        item.done = doneIds.contains(item.id);
      }

      themeMode = switch (theme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    } catch (_) {
      checklist = SampleData.checklist();
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
        'savedPlaceIds': _savedPlaceIds.toList(),
        'savedFacilityIds': _savedFacilityIds.toList(),
        'doneIds': [
          for (final item in checklist)
            if (item.done) item.id,
        ],
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
  bool isPlaceSaved(String id) => _savedPlaceIds.contains(id);
  bool isFacilitySaved(String id) => _savedFacilityIds.contains(id);

  List<SurvivalTip> get savedTips =>
      tips.where((tip) => _savedTipIds.contains(tip.id)).toList();

  List<CityPlace> get savedPlaces =>
      places.where((place) => _savedPlaceIds.contains(place.id)).toList();

  List<CampusFacility> get savedFacilities => university.facilities
      .where((facility) => _savedFacilityIds.contains(facility.id))
      .toList();

  int get totalSavedCount =>
      _savedTipIds.length + _savedPlaceIds.length + _savedFacilityIds.length;

  int get checklistDone => checklist.where((item) => item.done).length;

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

  void toggleSavePlace(String id) {
    if (_savedPlaceIds.contains(id)) {
      _savedPlaceIds.remove(id);
    } else {
      _savedPlaceIds.add(id);
    }
    notifyListeners();
    _persist();
  }

  void toggleSaveFacility(String id) {
    if (_savedFacilityIds.contains(id)) {
      _savedFacilityIds.remove(id);
    } else {
      _savedFacilityIds.add(id);
    }
    notifyListeners();
    _persist();
  }

  void toggleChecklist(ChecklistItem item) {
    item.done = !item.done;
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
