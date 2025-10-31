import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodayExercisesModel extends ChangeNotifier {
  static const String _selectedExercisesKey = 'selected_exercises';

  List<String> _selectedExerciseIds = [];

  TodayExercisesModel() {
    _loadSelectedExercises();
  }

  List<String> get selectedExerciseIds => List.from(_selectedExerciseIds);

  bool isExerciseSelected(String exerciseId) {
    return _selectedExerciseIds.contains(exerciseId);
  }

  void toggleExercise(String exerciseId) {
    if (_selectedExerciseIds.contains(exerciseId)) {
      _selectedExerciseIds.remove(exerciseId);
    } else {
      _selectedExerciseIds.add(exerciseId);
    }
    _saveSelectedExercises();
    notifyListeners();
  }

  void selectAll(List<String> allExerciseIds) {
    _selectedExerciseIds = List.from(allExerciseIds);
    _saveSelectedExercises();
    notifyListeners();
  }

  void deselectAll() {
    _selectedExerciseIds.clear();
    _saveSelectedExercises();
    notifyListeners();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String exerciseId = _selectedExerciseIds.removeAt(oldIndex);
    _selectedExerciseIds.insert(newIndex, exerciseId);
    _saveSelectedExercises();
    notifyListeners();
  }

  Future<void> _loadSelectedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedExercisesJson = prefs.getString(_selectedExercisesKey);

    if (selectedExercisesJson != null) {
      try {
        final List<dynamic> selectedList = List<dynamic>.from(json.decode(selectedExercisesJson));
        _selectedExerciseIds = selectedList.map((id) => id.toString()).toList();
      } catch (e) {
        // If parsing fails, initialize with default selection (all exercises)
        _initializeDefaultSelection();
      }
    } else {
      _initializeDefaultSelection();
    }
    notifyListeners();
  }

  void _initializeDefaultSelection() {
    // Select all exercises by default
    _selectedExerciseIds = [
      'foot_ball_rolling',
      'ball_tiptoe',
      'yoga_brick_tiptoe',
      'yoga_brick_ball_pickup',
      'frog_pose',
      'glute_bridge',
      'stretching',
    ];
  }

  Future<void> _saveSelectedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedExercisesKey, json.encode(_selectedExerciseIds));
  }
}