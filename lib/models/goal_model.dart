import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseGoal {
  final String exerciseId;
  final String exerciseName;
  int repsPerSet; // 每组次数
  int targetSeconds;
  int restInterval;
  bool hasLeftRight;
  int leftTarget;
  int rightTarget;
  int sets; // 训练组数
  int countInterval; // 计数中时长（秒）
  int prepareInterval; // 准备中时长（秒）
  int leftRightSeconds; // 左右滚动时长（秒）
  int frontBackSeconds; // 前后滚动时长（秒）
  int heelSeconds; // 脚后跟滚动时长（秒）
  int trainingInterval; // 训练项目间隔时长（秒）

  ExerciseGoal({
    required this.exerciseId,
    required this.exerciseName,
    this.repsPerSet = 10,
    this.targetSeconds = 30,
    this.restInterval = 10,
    this.hasLeftRight = false,
    this.leftTarget = 10,
    this.rightTarget = 10,
    this.sets = 3, // 默认3组
    this.countInterval = 5, // 默认5秒
    this.prepareInterval = 1, // 默认1秒
    this.leftRightSeconds = 60, // 默认60秒
    this.frontBackSeconds = 60, // 默认60秒
    this.heelSeconds = 60, // 默认60秒
    this.trainingInterval = 30, // 默认30秒
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'repsPerSet': repsPerSet,
      'targetSeconds': targetSeconds,
      'restInterval': restInterval,
      'hasLeftRight': hasLeftRight,
      'leftTarget': leftTarget,
      'rightTarget': rightTarget,
      'sets': sets,
      'countInterval': countInterval,
      'prepareInterval': prepareInterval,
      'leftRightSeconds': leftRightSeconds,
      'frontBackSeconds': frontBackSeconds,
      'heelSeconds': heelSeconds,
      'trainingInterval': trainingInterval,
    };
  }

  factory ExerciseGoal.fromJson(Map<String, dynamic> json) {
    return ExerciseGoal(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      repsPerSet: json['repsPerSet'] ?? json['targetCount'] ?? 10, // 向后兼容
      targetSeconds: json['targetSeconds'] ?? 30,
      restInterval: json['restInterval'] ?? 10,
      hasLeftRight: json['hasLeftRight'] ?? false,
      leftTarget: json['leftTarget'] ?? 10,
      rightTarget: json['rightTarget'] ?? 10,
      sets: json['sets'] ?? 3,
      countInterval: json['countInterval'] ?? 5,
      prepareInterval: json['prepareInterval'] ?? 1,
      leftRightSeconds: json['leftRightSeconds'] ?? 60,
      frontBackSeconds: json['frontBackSeconds'] ?? 60,
      heelSeconds: json['heelSeconds'] ?? 60,
      trainingInterval: json['trainingInterval'] ?? 30,
    );
  }
}

class GoalModel extends ChangeNotifier {
  static const String _goalsKey = 'exercise_goals';

  final Map<String, ExerciseGoal> _exerciseGoals = {};

  GoalModel() {
    _loadGoals();
  }

  List<ExerciseGoal> get goals {
    // Define the desired order of exercises, with foot_ball_rolling first
    const List<String> exerciseOrder = [
      'foot_ball_rolling',
      'ball_tiptoe',
      'yoga_brick_tiptoe',
      'yoga_brick_ball_pickup',
      'frog_pose',
      'glute_bridge',
      'stretching',
    ];

    // Create a list in the desired order
    final List<ExerciseGoal> orderedGoals = [];
    for (final exerciseId in exerciseOrder) {
      final goal = _exerciseGoals[exerciseId];
      if (goal != null) {
        orderedGoals.add(goal);
      }
    }

    return orderedGoals;
  }

  ExerciseGoal? getGoal(String exerciseId) {
    return _exerciseGoals[exerciseId];
  }

  void setGoal(ExerciseGoal goal) {
    _exerciseGoals[goal.exerciseId] = goal;
    _saveGoals();
    notifyListeners();
  }

  void setRepsPerSet(String exerciseId, int count) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.repsPerSet = count;
      _saveGoals();
      notifyListeners();
    }
  }

  void setTargetSeconds(String exerciseId, int seconds) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.targetSeconds = seconds;
      _saveGoals();
      notifyListeners();
    }
  }

  void setRestInterval(String exerciseId, int interval) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.restInterval = interval;
      _saveGoals();
      notifyListeners();
    }
  }

  void setLeftRightTargets(String exerciseId, int leftTarget, int rightTarget) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.leftTarget = leftTarget;
      goal.rightTarget = rightTarget;
      _saveGoals();
      notifyListeners();
    }
  }

  void setSets(String exerciseId, int sets) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.sets = sets;
      _saveGoals();
      notifyListeners();
    }
  }

  void setCountInterval(String exerciseId, int interval) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.countInterval = interval;
      _saveGoals();
      notifyListeners();
    }
  }

  void setPrepareInterval(String exerciseId, int interval) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.prepareInterval = interval;
      _saveGoals();
      notifyListeners();
    }
  }

  void setRollingTypeDurations(String exerciseId, int leftRightSeconds, int frontBackSeconds, int heelSeconds) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.leftRightSeconds = leftRightSeconds;
      goal.frontBackSeconds = frontBackSeconds;
      goal.heelSeconds = heelSeconds;
      _saveGoals();
      notifyListeners();
    }
  }

  void setTrainingInterval(String exerciseId, int interval) {
    final goal = _exerciseGoals[exerciseId];
    if (goal != null) {
      goal.trainingInterval = interval;
      _saveGoals();
      notifyListeners();
    }
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);

    if (goalsJson != null) {
      try {
        final List<dynamic> goalsList = List<dynamic>.from(json.decode(goalsJson));
        for (final goalData in goalsList) {
          final goal = ExerciseGoal.fromJson(Map<String, dynamic>.from(goalData));
          _exerciseGoals[goal.exerciseId] = goal;
        }
        // Ensure foot_ball_rolling goal exists (migration for existing users)
        if (!_exerciseGoals.containsKey('foot_ball_rolling')) {
          _exerciseGoals['foot_ball_rolling'] = ExerciseGoal(
            exerciseId: 'foot_ball_rolling',
            exerciseName: '脚底滚球',
            repsPerSet: 10,
            targetSeconds: 60,
            restInterval: 10,
            sets: 1,
            hasLeftRight: true,
            leftTarget: 60,
            rightTarget: 60,
            leftRightSeconds: 60,
            frontBackSeconds: 60,
            heelSeconds: 60,
            trainingInterval: 30,
          );
          _saveGoals();
        }
      } catch (e) {
        // If parsing fails, initialize with default goals
        _initializeDefaultGoals();
      }
    } else {
      _initializeDefaultGoals();
    }
    notifyListeners();
  }

  void _initializeDefaultGoals() {
    // Initialize with default goals for all exercises
    _exerciseGoals['foot_ball_rolling'] = ExerciseGoal(
      exerciseId: 'foot_ball_rolling',
      exerciseName: '脚底滚球',
      repsPerSet: 10,
      targetSeconds: 60, // 默认60秒
      restInterval: 10,
      sets: 1,
      hasLeftRight: true, // 区分左右脚
      leftTarget: 60, // 左脚目标60秒
      rightTarget: 60, // 右脚目标60秒
      leftRightSeconds: 60, // 左右滚动默认60秒
      frontBackSeconds: 60, // 前后滚动默认60秒
      heelSeconds: 60, // 脚后跟滚动默认60秒
      trainingInterval: 30, // 默认30秒
    );

    _exerciseGoals['ball_tiptoe'] = ExerciseGoal(
      exerciseId: 'ball_tiptoe',
      exerciseName: '夹球踮脚',
      repsPerSet: 20,
      targetSeconds: 30,
      restInterval: 10,
      sets: 3,
      trainingInterval: 30, // 默认30秒
    );

    _exerciseGoals['yoga_brick_tiptoe'] = ExerciseGoal(
      exerciseId: 'yoga_brick_tiptoe',
      exerciseName: '瑜伽砖踮脚',
      repsPerSet: 15,
      targetSeconds: 30,
      restInterval: 10,
      sets: 3,
      trainingInterval: 30, // 默认30秒
    );

    _exerciseGoals['yoga_brick_ball_pickup'] = ExerciseGoal(
      exerciseId: 'yoga_brick_ball_pickup',
      exerciseName: '瑜伽砖捡球',
      repsPerSet: 10,
      targetSeconds: 30,
      restInterval: 10,
      hasLeftRight: true,
      leftTarget: 10,
      rightTarget: 10,
      sets: 3,
      trainingInterval: 30, // 默认30秒
    );

    _exerciseGoals['frog_pose'] = ExerciseGoal(
      exerciseId: 'frog_pose',
      exerciseName: '青蛙趴',
      repsPerSet: 5,
      targetSeconds: 60,
      restInterval: 30,
      sets: 1,
      trainingInterval: 30, // 默认30秒
    );

    _exerciseGoals['glute_bridge'] = ExerciseGoal(
      exerciseId: 'glute_bridge',
      exerciseName: '臀桥',
      repsPerSet: 15,
      targetSeconds: 30,
      restInterval: 10,
      sets: 3,
      trainingInterval: 30, // 默认30秒
    );

    _exerciseGoals['stretching'] = ExerciseGoal(
      exerciseId: 'stretching',
      exerciseName: '拉伸',
      repsPerSet: 5,
      targetSeconds: 60,
      restInterval: 30,
      sets: 1,
      trainingInterval: 30, // 默认30秒
    );
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsList = _exerciseGoals.values.map((goal) => goal.toJson()).toList();
    await prefs.setString(_goalsKey, json.encode(goalsList));
  }

  // Calculate total daily goal (sum of all exercise targets)
  int getTotalDailyGoal() {
    return _exerciseGoals.values.fold(0, (sum, goal) => sum + goal.repsPerSet);
  }

  // Check if exercise goal is achieved
  bool isExerciseGoalAchieved(String exerciseId, int completedCount) {
    final goal = _exerciseGoals[exerciseId];
    return goal != null && completedCount >= goal.repsPerSet;
  }
}