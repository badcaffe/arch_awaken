import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../services/sound_service.dart';
import 'training_completion_screen.dart';

class TimerScreen extends StatefulWidget {
  final String exerciseId;

  const TimerScreen({
    super.key,
    required this.exerciseId,
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

    // Check if we're in sequential training mode and auto-start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trainingModel = Provider.of<TrainingModel>(context, listen: false);
      // Auto-start if sequential mode is enabled
      if (trainingModel.isSequentialMode) {
        _startTimer();
      }
    });
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
    final record = TrainingRecord(
      exerciseId: widget.exerciseId,
      date: DateTime.now(),
      duration: _initialTime,
      count: 1,
    );
    trainingModel.addRecord(record);

    // Play cheer sound
    final soundService = SoundService();
    soundService.playCheerSound();

    // Check if we're in sequential training mode
    if (trainingModel.isSequentialTrainingActive) {
      final nextExerciseId = trainingModel.getNextSequentialExercise();

      if (nextExerciseId != null) {
        // Show completion screen with next training option
        _showCompletionScreen(nextExerciseId: nextExerciseId);
      } else {
        // End of sequence
        trainingModel.stopSequentialTraining();
        _showCompletionScreen();
      }
    } else {
      _showCompletionScreen();
    }
  }

  void _startNextTraining(String nextExerciseId, TrainingModel trainingModel) {
    final nextExercise = trainingModel.getExerciseById(nextExerciseId);

    if (nextExercise != null) {
      if (nextExerciseId == 'foot_ball_rolling') {
        context.go('/foot-ball-rolling/$nextExerciseId');
      } else if (nextExercise.type == ExerciseType.timer) {
        // 青蛙趴和拉伸使用组计时器，其他计时训练使用简单计时器
        if (nextExerciseId == 'frog_pose' || nextExerciseId == 'stretching') {
          context.go('/group-timer/$nextExerciseId');
        } else {
          context.go('/timer/$nextExerciseId');
        }
      } else {
        context.go('/counter/$nextExerciseId');
      }
    }
  }

  void _showCompletionScreen({String? nextExerciseId}) {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TrainingCompletionScreen(
        exerciseId: widget.exerciseId,
        count: 1,
        duration: _initialTime,
        sets: 1,
        repsPerSet: 1,
        onRestart: () {
          Navigator.of(context).pop();
          _resetTimer();
          _startTimer();
        },
        onReturnHome: () {
          Navigator.of(context).pop();
          context.pop();
        },
        onNextTraining: nextExerciseId != null ? () {
          Navigator.of(context).pop();
          _startNextTraining(nextExerciseId, trainingModel);
          // 延迟移动到下一个练习，确保新页面能正确获取当前练习ID
          WidgetsBinding.instance.addPostFrameCallback((_) {
            trainingModel.moveToNextSequentialExercise();
          });
        } : null,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Clear sequential mode when back button is pressed
            trainingModel.clearSequentialMode();
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          // 可滚动的内容区域
          Expanded(
            child: SingleChildScrollView(
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
                  ],
                ),
              ),
            ),
          ),

          // 底部固定的控制按钮区域
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
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
          ),
        ],
      ),
    );
  }
}