import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';

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

    // Show completion dialog
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
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: exercise.color.withOpacity(0.1),
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
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  )
                else if (_isRunning)
                  ElevatedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('暂停'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  )
                else if (!_isRunning && _remainingTime < _initialTime)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('继续'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重置'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}