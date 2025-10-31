import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_model.dart';

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
      id: 'foot_ball_rolling',
      name: '脚底滚球',
      description: '',
      type: ExerciseType.timer,
      icon: Icons.sports_baseball,
      color: Colors.grey, // Will be overridden by theme
    ),
    TrainingExercise(
      id: 'ball_tiptoe',
      name: '夹球踮脚',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.sports_baseball,
      color: Colors.grey, // Will be overridden by theme
    ),
    TrainingExercise(
      id: 'yoga_brick_tiptoe',
      name: '瑜伽砖踮脚',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.square,
      color: Colors.grey, // Will be overridden by theme
    ),
    TrainingExercise(
      id: 'yoga_brick_ball_pickup',
      name: '瑜伽砖捡球',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.sports_baseball_outlined,
      color: Colors.grey, // Will be overridden by theme
    ),
    TrainingExercise(
      id: 'frog_pose',
      name: '青蛙趴',
      description: '',
      type: ExerciseType.timer,
      icon: Icons.accessibility,
      color: Colors.grey, // Will be overridden by theme
    ),
    TrainingExercise(
      id: 'glute_bridge',
      name: '臀桥',
      description: '',
      type: ExerciseType.counter,
      icon: Icons.fitness_center,
      color: Colors.grey, // Will be overridden by theme
    ),
    TrainingExercise(
      id: 'stretching',
      name: '拉伸',
      description: '',
      type: ExerciseType.timer,
      icon: Icons.self_improvement,
      color: Colors.grey, // Will be overridden by theme
    ),
  ];

  List<TrainingRecord> _records = [];
  List<TrainingRecord> get records => _records;

  // Exercise target counts
  Map<String, int> _exerciseTargets = {};

  // Achievement tracking
  Set<String> _unlockedAchievements = {};
  Set<String> get unlockedAchievements => _unlockedAchievements;

  TrainingModel() {
    _loadRecords();
    _loadAchievements();
    _loadExerciseTargets();
  }

  List<TrainingExercise> get exercises => _exercises;

  List<TrainingExercise> getExercisesWithTheme(ThemeModel themeModel) {
    return _exercises.map((exercise) {
      return TrainingExercise(
        id: exercise.id,
        name: exercise.name,
        description: exercise.description,
        type: exercise.type,
        icon: exercise.icon,
        color: themeModel.getExerciseColor(exercise.id),
      );
    }).toList();
  }

  TrainingExercise? getExerciseById(String id) {
    return _exercises.firstWhere((exercise) => exercise.id == id);
  }

  void addRecord(TrainingRecord record) {
    _records.add(record);
    _saveRecords();
    checkAndUnlockAchievements();
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

  // Achievement methods
  void unlockAchievement(String achievementId) {
    if (!_unlockedAchievements.contains(achievementId)) {
      _unlockedAchievements.add(achievementId);
      _saveAchievements();
      notifyListeners();
    }
  }

  bool hasAchievement(String achievementId) {
    return _unlockedAchievements.contains(achievementId);
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsList = prefs.getStringList('achievements') ?? [];
    _unlockedAchievements = Set<String>.from(achievementsList);
    notifyListeners();
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('achievements', _unlockedAchievements.toList());
  }

  // Exercise target methods
  int getExerciseTarget(String exerciseId) {
    // 如果目标未设置，根据训练类型返回默认值
    final exercise = getExerciseById(exerciseId);
    int defaultTarget = 10; // 默认计数器训练目标
    if (exercise != null && exercise.type == ExerciseType.timer) {
      defaultTarget = 60; // 计时器训练默认60秒
    }

    final target = _exerciseTargets[exerciseId] ?? defaultTarget;
    print('📊 获取训练目标: $exerciseId -> $target (默认: $defaultTarget)');
    return target;
  }

  void setExerciseTarget(String exerciseId, int target) {
    print('🎯 设置训练目标: $exerciseId -> $target');
    _exerciseTargets[exerciseId] = target;
    print('📝 当前训练目标: $_exerciseTargets');
    _saveExerciseTargets();
    notifyListeners();
  }

  Future<void> _loadExerciseTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final targetsJson = prefs.getString('exercise_targets');
    print('📥 从存储加载训练目标: $targetsJson');
    if (targetsJson != null) {
      final Map<String, dynamic> targetsMap = json.decode(targetsJson);
      _exerciseTargets = targetsMap.map((key, value) => MapEntry(key, value as int));
      print('📥 加载训练目标完成: $_exerciseTargets');
    } else {
      print('📥 没有找到保存的训练目标，使用默认值');
    }
  }

  Future<void> _saveExerciseTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final targetsJson = json.encode(_exerciseTargets);
    print('💾 保存训练目标到存储: $targetsJson');
    await prefs.setString('exercise_targets', targetsJson);
    print('✅ 训练目标保存完成');
  }

  // Achievement checking methods
  void checkAndUnlockAchievements() {
    // Check for 7-day streak
    if (_hasSevenDayStreak() && !hasAchievement('7_day_streak')) {
      unlockAchievement('7_day_streak');
    }

    // Check for first week completion
    if (_hasCompletedFirstWeek() && !hasAchievement('first_week')) {
      unlockAchievement('first_week');
    }

    // Check for arch awakening (one month)
    if (_hasArchAwakening() && !hasAchievement('arch_awakening')) {
      unlockAchievement('arch_awakening');
    }

    // Check for ball tiptoe expert
    if (_hasBallTiptoeExpert() && !hasAchievement('ball_tiptoe_expert')) {
      unlockAchievement('ball_tiptoe_expert');
    }

    // Check for yoga master
    if (_hasYogaMaster() && !hasAchievement('yoga_master')) {
      unlockAchievement('yoga_master');
    }

    // Check for stretching expert
    if (_hasStretchingExpert() && !hasAchievement('stretching_expert')) {
      unlockAchievement('stretching_expert');
    }
  }

  bool _hasSevenDayStreak() {
    // Simple implementation - check if user has trained for 7 consecutive days
    final today = DateTime.now();
    final trainingDays = <DateTime>{};

    for (var record in _records) {
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      trainingDays.add(date);
    }

    // Check for 7 consecutive days
    for (int i = 0; i < 7; i++) {
      final checkDate = today.subtract(Duration(days: i));
      if (!trainingDays.contains(checkDate)) {
        return false;
      }
    }
    return true;
  }

  bool _hasCompletedFirstWeek() {
    // Check if user has at least 7 training days total
    final trainingDays = <DateTime>{};
    for (var record in _records) {
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      trainingDays.add(date);
    }
    return trainingDays.length >= 7;
  }

  bool _hasBallTiptoeExpert() {
    // Check if user has completed 100 ball tiptoe exercises
    final ballTiptoeRecords = _records
        .where((record) => record.exerciseId == 'ball_tiptoe')
        .toList();
    if (ballTiptoeRecords.isEmpty) return false;
    final totalCount = ballTiptoeRecords
        .map((record) => record.count)
        .reduce((a, b) => a + b);
    return totalCount >= 100;
  }

  bool _hasArchAwakening() {
    // Check if user has at least 30 training days total
    final trainingDays = <DateTime>{};
    for (var record in _records) {
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      trainingDays.add(date);
    }
    return trainingDays.length >= 30;
  }

  bool _hasYogaMaster() {
    // Check if user has completed all yoga brick exercises
    final yogaBrickTiptoeRecords = _records
        .where((record) => record.exerciseId == 'yoga_brick_tiptoe')
        .toList();
    final yogaBrickBallRecords = _records
        .where((record) => record.exerciseId == 'yoga_brick_ball_pickup')
        .toList();

    if (yogaBrickTiptoeRecords.isEmpty || yogaBrickBallRecords.isEmpty) return false;

    final tiptoeTotal = yogaBrickTiptoeRecords
        .map((record) => record.count)
        .reduce((a, b) => a + b);
    final ballTotal = yogaBrickBallRecords
        .map((record) => record.count)
        .reduce((a, b) => a + b);

    return tiptoeTotal >= 50 && ballTotal >= 50;
  }

  bool _hasStretchingExpert() {
    // Check if user has accumulated 60 minutes of stretching
    final stretchingRecords = _records
        .where((record) => record.exerciseId == 'stretching')
        .toList();
    if (stretchingRecords.isEmpty) return false;
    final totalDuration = stretchingRecords
        .map((record) => record.duration)
        .reduce((a, b) => a + b);
    return totalDuration >= 3600; // 60 minutes in seconds
  }
}