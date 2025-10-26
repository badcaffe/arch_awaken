import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';

class CounterScreen extends StatefulWidget {
  final String exerciseId;

  const CounterScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  bool _isRunning = false;
  bool _isCountingDown = false;
  int _countdownValue = 5;
  Timer? _countdownTimer;
  Timer? _trainingTimer;
  int _trainingDuration = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _trainingTimer?.cancel();
    super.dispose();
  }

  void _startTraining() {
    setState(() {
      _isRunning = true;
      _isCountingDown = true;
      _countdownValue = 5;
    });

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownValue > 1) {
          _countdownValue--;
        } else {
          _isCountingDown = false;
          _countdownValue = 5;
          timer.cancel();
          _startTrainingTimer();
        }
      });
    });
  }

  void _startTrainingTimer() {
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _trainingDuration++;
      });
    });
  }

  void _incrementCount() {
    setState(() {
      _count++;
    });
  }

  void _pauseTraining() {
    setState(() {
      _isRunning = false;
    });
    _countdownTimer?.cancel();
    _trainingTimer?.cancel();
  }

  void _resetTraining() {
    setState(() {
      _count = 0;
      _isRunning = false;
      _isCountingDown = false;
      _countdownValue = 5;
      _trainingDuration = 0;
    });
    _countdownTimer?.cancel();
    _trainingTimer?.cancel();
  }

  void _completeTraining() {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final record = TrainingRecord(
      exerciseId: widget.exerciseId,
      date: DateTime.now(),
      duration: _trainingDuration,
      count: _count,
    );
    trainingModel.addRecord(record);

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('训练完成'),
        content: Text('完成 $_count 次训练，用时 ${_trainingDuration} 秒'),
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
            if (_isCountingDown)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00695C).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00695C),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _countdownValue.toString(),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00695C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '准备开始',
                    style: TextStyle(
                      fontSize: 24,
                      color: const Color(0xFF00695C),
                    ),
                  ),
                ],
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
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
                        _count.toString(),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: exercise.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '训练次数',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '用时: ${_trainingDuration}秒',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
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
            if (!_isRunning && _count == 0)
              ElevatedButton.icon(
                onPressed: _startTraining,
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始训练'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              )
            else if (_isRunning && !_isCountingDown)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _incrementCount,
                    icon: const Icon(Icons.add),
                    label: const Text('完成一次'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: exercise.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pauseTraining,
                    icon: const Icon(Icons.pause),
                    label: const Text('暂停'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              )
            else if (!_isRunning && _count > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _startTraining,
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
                    onPressed: _completeTraining,
                    icon: const Icon(Icons.check),
                    label: const Text('完成'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_count > 0 || _isRunning)
              ElevatedButton.icon(
                onPressed: _resetTraining,
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
      ),
    );
  }
}