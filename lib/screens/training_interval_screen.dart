import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';

class TrainingIntervalScreen extends StatefulWidget {
  final Map<String, dynamic>? params;

  const TrainingIntervalScreen({
    super.key,
    this.params,
  });

  @override
  State<TrainingIntervalScreen> createState() => _TrainingIntervalScreenState();
}

class _TrainingIntervalScreenState extends State<TrainingIntervalScreen> {
  late int _remainingSeconds;
  late Timer _timer;

  String get currentExerciseId => widget.params?['currentExerciseId'] ?? '';
  String get nextExerciseId => widget.params?['nextExerciseId'] ?? '';
  int get intervalSeconds => widget.params?['intervalSeconds'] ?? 30;
  int get currentIndex => widget.params?['currentIndex'] ?? 0;
  int get totalCount => widget.params?['totalCount'] ?? 1;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = intervalSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _startNextTraining();
        }
      });
    });
  }

  void _startNextTraining() {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
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

  void _stopTrainingSequence() {
    _timer.cancel();
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    trainingModel.stopSequentialTraining();
    context.go('/'); // 返回今日页面
  }

  void _skipInterval() {
    _timer.cancel();
    _startNextTraining();
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final currentExercise = trainingModel.getExerciseById(currentExerciseId);
    final nextExercise = trainingModel.getExerciseById(nextExerciseId);

    if (currentExercise == null || nextExercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('训练间隔'),
        ),
        body: const Center(
          child: Text('训练项目不存在'),
        ),
      );
    }

    final currentExerciseColor = themeModel.getExerciseColor(currentExerciseId);
    final nextExerciseColor = themeModel.getExerciseColor(nextExerciseId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练间隔'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 进度指示器
            Text(
              '${currentIndex + 1}/$totalCount',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // 当前完成的项目
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: currentExerciseColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        currentExercise.icon,
                        color: currentExerciseColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '已完成: ${currentExercise.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '✓ 训练完成',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 倒计时显示
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  '$_remainingSeconds',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '准备下一个训练项目',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 30),

            // 下一个训练项目
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: nextExerciseColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        nextExercise.icon,
                        color: nextExerciseColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextExercise.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextExercise.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stopTrainingSequence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '停止训练',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _skipInterval,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '跳过间隔',
                      style: TextStyle(fontSize: 16),
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