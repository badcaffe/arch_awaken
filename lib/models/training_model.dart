import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ExerciseType { timer, counter }

class TrainingExercise {
  final String id;
  final String name;
  final String description;
  final ExerciseType type;
  final IconData icon;
  final Color color;

  const TrainingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
  });
}

class TrainingRecord {
  final String exerciseId;
  final DateTime date;
  final int duration; // in seconds for timer, count for counter
  final int count; // for counter exercises

  TrainingRecord({
    required this.exerciseId,
    required this.date,
    required this.duration,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'duration': duration,
      'count': count,
    };
  }

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      exerciseId: json['exerciseId'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      count: json['count'],
    );
  }
}

class TrainingModel extends ChangeNotifier {
  static const List<TrainingExercise> _exercises = [
    TrainingExercise(
      id: 'ball_tiptoe',
      name: '夹球踮脚',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.sports_baseball,
      color: const Color(0xFF00695C), // Deep teal
    ),
    TrainingExercise(
      id: 'yoga_brick_tiptoe',
      name: '瑜伽砖踮脚',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.square,
      color: const Color(0xFF00796B), // Medium teal
    ),
    TrainingExercise(
      id: 'yoga_brick_ball_pickup',
      name: '瑜伽砖捡球',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.sports_baseball_outlined,
      color: const Color(0xFF009688), // Bright teal
    ),
    TrainingExercise(
      id: 'frog_pose',
      name: '青蛙趴',
      description: '',
      type: ExerciseType.timer,
      icon: Icons.accessibility,
      color: const Color(0xFF4DB6AC), // Light teal
    ),
    TrainingExercise(
      id: 'glute_bridge',
      name: '臀桥',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.fitness_center,
      color: const Color(0xFF1976D2), // Peacock blue
    ),
    TrainingExercise(
      id: 'stretching',
      name: '拉伸',
      description: '',
      type: ExerciseType.timer,
      icon: Icons.self_improvement,
      color: const Color(0xFF7B1FA2), // Peacock purple
    ),
  ];

  List<TrainingRecord> _records = [];
  List<TrainingRecord> get records => _records;

  TrainingModel() {
    _loadRecords();
  }

  List<TrainingExercise> get exercises => _exercises;

  TrainingExercise? getExerciseById(String id) {
    return _exercises.firstWhere((exercise) => exercise.id == id);
  }

  void addRecord(TrainingRecord record) {
    _records.add(record);
    _saveRecords();
    notifyListeners();
  }

  List<TrainingRecord> getRecordsByExercise(String exerciseId) {
    return _records
        .where((record) => record.exerciseId == exerciseId)
        .toList();
  }

  List<TrainingRecord> getTodayRecords() {
    final today = DateTime.now();
    return _records.where((record) {
      return record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day;
    }).toList();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList('training_records') ?? [];
    _records = recordsJson
        .map((jsonString) => TrainingRecord.fromJson(
            Map<String, dynamic>.from(json.decode(jsonString))))
        .toList();
    notifyListeners();
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = _records
        .map((record) => json.encode(record.toJson()))
        .toList();
    await prefs.setStringList('training_records', recordsJson);
  }
}