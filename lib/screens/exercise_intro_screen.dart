import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../services/sound_service.dart';

class ExerciseIntroScreen extends StatefulWidget {
  final String exerciseId;

  const ExerciseIntroScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ExerciseIntroScreen> createState() => _ExerciseIntroScreenState();
}

class _ExerciseIntroScreenState extends State<ExerciseIntroScreen> {
  final SoundService _soundService = SoundService();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _playIntroAndNavigate();
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  Future<void> _playIntroAndNavigate() async {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final exercise = trainingModel.getExerciseById(widget.exerciseId);

    if (exercise == null) {
      _navigateToTraining();
      return;
    }

    // Start timing to ensure minimum 2 seconds display
    final startTime = DateTime.now();

    // Play exercise name audio
    final soundPath = 'sounds/${exercise.name}.mp3';
    print('🎵 尝试播放练习音频: $soundPath');
    try {
      await _soundService.playCustomSound(soundPath);
      print('✅ 练习音频播放成功: $soundPath');
    } catch (e) {
      print('❌ 练习音频播放失败: $soundPath, 错误: $e');
      // If sound fails, silently continue
    }

    // Calculate remaining time to reach 2 seconds minimum
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remainingTime = 2000 - elapsed;

    if (remainingTime > 0) {
      await Future.delayed(Duration(milliseconds: remainingTime));
    }

    // Navigate to training screen
    if (mounted && !_isNavigating) {
      _navigateToTraining();
    }
  }

  void _navigateToTraining() {
    if (_isNavigating) return;
    _isNavigating = true;

    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final exercise = trainingModel.getExerciseById(widget.exerciseId);

    if (exercise == null) {
      context.pop();
      return;
    }

    String route;
    if (widget.exerciseId == 'foot_ball_rolling') {
      route = '/foot-ball-rolling/${widget.exerciseId}';
    } else if (exercise.type == ExerciseType.timer) {
      // 青蛙趴和拉伸使用组计时器，其他计时训练使用简单计时器
      if (widget.exerciseId == 'frog_pose' || widget.exerciseId == 'stretching') {
        route = '/group-timer/${widget.exerciseId}';
      } else {
        route = '/timer/${widget.exerciseId}';
      }
    } else {
      route = '/counter/${widget.exerciseId}';
    }

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final exercise = trainingModel.getExerciseById(widget.exerciseId);

    if (exercise == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final exerciseColor = themeModel.getExerciseColor(widget.exerciseId);

    return Scaffold(
      backgroundColor: exerciseColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exercise Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                exercise.icon,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            // Exercise Name
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Exercise Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                exercise.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
