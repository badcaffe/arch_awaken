import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import 'sequential_training_completion_dialog.dart';

class TimerScreen extends StatefulWidget {
  final String exerciseId;
  final bool autoStart;

  const TimerScreen({
    super.key,
    required this.exerciseId,
    this.autoStart = false,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int _initialTime = 60; // 60 seconds
  int _remainingTime = _initialTime;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = _initialTime;

    // Auto start training if specified
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startTimer();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isRunning = false;
          timer.cancel();
          _saveRecord();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingTime = _initialTime;
    });
    _timer?.cancel();
  }

  void _saveRecord() {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final goalModel = Provider.of<GoalModel>(context, listen: false);
    final record = TrainingRecord(
      exerciseId: widget.exerciseId,
      date: DateTime.now(),
      duration: _initialTime,
      count: 1,
    );
    trainingModel.addRecord(record);

    // Check if we're in sequential training mode
    if (trainingModel.isSequentialTrainingActive) {
      final currentExerciseId = trainingModel.getCurrentSequentialExercise();
      final nextExerciseId = trainingModel.getNextSequentialExercise();

      if (nextExerciseId != null) {
        // Show completion screen with next training option
        _showSequentialCompletionDialog(currentExerciseId, nextExerciseId, trainingModel, goalModel);
      } else {
        // End of sequence
        trainingModel.stopSequentialTraining();
        _showCompletionDialog();
      }
    } else {
      _showCompletionDialog();
    }
  }

  void _showSequentialCompletionDialog(String? currentExerciseId, String? nextExerciseId, TrainingModel trainingModel, GoalModel goalModel) {
    final goal = goalModel.getGoal(currentExerciseId ?? '');
    final intervalSeconds = goal?.trainingInterval ?? 30;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SequentialTrainingCompletionDialog(
        currentExerciseId: currentExerciseId ?? '',
        nextExerciseId: nextExerciseId ?? '',
        intervalSeconds: intervalSeconds,
        onContinue: () {
          Navigator.of(context).pop();
          // Move to next exercise and start training
          trainingModel.moveToNextSequentialExercise();
          _startNextTraining(nextExerciseId ?? '', trainingModel);
        },
        onStop: () {
          Navigator.of(context).pop();
          trainingModel.stopSequentialTraining();
          context.pop();
        },
      ),
    );
  }

  void _startNextTraining(String nextExerciseId, TrainingModel trainingModel) {
    final nextExercise = trainingModel.getExerciseById(nextExerciseId);

    if (nextExercise != null) {
      if (nextExerciseId == 'foot_ball_rolling') {
        context.go('/foot-ball-rolling/$nextExerciseId?autoStart=true');
      } else if (nextExercise.type == ExerciseType.timer) {
        // 青蛙趴和拉伸使用组计时器，其他计时训练使用简单计时器
        if (nextExerciseId == 'frog_pose' || nextExerciseId == 'stretching') {
          context.go('/group-timer/$nextExerciseId?autoStart=true');
        } else {
          context.go('/timer/$nextExerciseId?autoStart=true');
        }
      } else {
        context.go('/counter/$nextExerciseId?autoStart=true');
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('训练完成'),
        content: const Text('计时训练已完成！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final baseExercise = trainingModel.getExerciseById(widget.exerciseId);

    if (baseExercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('错误'),
        ),
        body: const Center(
          child: Text('训练项目不存在'),
        ),
      );
    }

    // Create exercise with theme color
    final exercise = TrainingExercise(
      id: baseExercise.id,
      name: baseExercise.name,
      description: baseExercise.description,
      type: baseExercise.type,
      icon: baseExercise.icon,
      color: themeModel.getExerciseColor(baseExercise.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        backgroundColor: exercise.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // 状态指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: exercise.color.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: exercise.color, width: 2),
              ),
              child: Text(
                _isRunning ? '训练中' : (_remainingTime == _initialTime ? '准备开始' : '暂停中'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: exercise.color,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: exercise.color.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: exercise.color,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  _formatTime(_remainingTime),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: exercise.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              exercise.description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isRunning && _remainingTime == _initialTime)
                  IconButton(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      iconSize: 32,
                    ),
                  )
                else if (_isRunning)
                  IconButton(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      iconSize: 32,
                    ),
                  )
                else if (!_isRunning && _remainingTime < _initialTime)
                  IconButton(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      iconSize: 32,
                    ),
                  ),
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    iconSize: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}