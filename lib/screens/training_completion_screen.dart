import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/training_model.dart';
import '../models/theme_model.dart';

class TrainingCompletionScreen extends StatefulWidget {
  final String exerciseId;
  final int count;
  final int duration;
  final int sets;
  final int repsPerSet;
  final VoidCallback onRestart;
  final VoidCallback onReturnHome;
  final VoidCallback? onStartNextTraining;
  final bool showNextTrainingButton;

  const TrainingCompletionScreen({
    super.key,
    required this.exerciseId,
    required this.count,
    required this.duration,
    required this.sets,
    required this.repsPerSet,
    required this.onRestart,
    required this.onReturnHome,
    this.onStartNextTraining,
    this.showNextTrainingButton = false,
  });

  @override
  State<TrainingCompletionScreen> createState() => _TrainingCompletionScreenState();
}

class _TrainingCompletionScreenState extends State<TrainingCompletionScreen> {
  // Countdown timer for sequential training
  Timer? _countdownTimer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();

    // Start countdown timer if this is part of sequential training
    if (widget.showNextTrainingButton && widget.onStartNextTraining != null) {
      _startCountdownTimer();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _countdownTimer?.cancel();
    print('🎯 训练完成屏幕: 开始下一训练, onStartNextTraining: ${widget.onStartNextTraining}');
    if (widget.onStartNextTraining != null) {
      print('🚀 执行下一训练回调');
      widget.onStartNextTraining!();
    } else {
      print('⚠️ onStartNextTraining 为 null，无法开始下一训练');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final exercise = trainingModel.getExerciseById(widget.exerciseId);
    final color = themeModel.getExerciseColor(widget.exerciseId);

    if (exercise == null) {
      return const SizedBox.shrink();
    }

    // Get next exercise for sequential training
    final nextExerciseId = trainingModel.getNextSequentialExercise();
    final nextExercise = nextExerciseId != null ? trainingModel.getExerciseById(nextExerciseId) : null;
    final nextExerciseColor = nextExerciseId != null ? themeModel.getExerciseColor(nextExerciseId) : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.85).toDouble(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with celebration
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(128),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '训练完成！',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Current exercise info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          exercise.icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '✓ 已完成',
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
                  const SizedBox(height: 20),

                  // Next exercise info (only show if there's a next exercise)
                  if (nextExercise != null && nextExerciseColor != null) ...[
                    Row(
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
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                '下一个训练项目',
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
                    const SizedBox(height: 24),
                  ],

                  // Countdown and continue button (only for sequential training)
                  if (widget.showNextTrainingButton && widget.onStartNextTraining != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withAlpha(50)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_remainingSeconds秒后开始下一个训练',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _startNextTraining,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '立即开始',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  if (_remainingSeconds > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '($_remainingSeconds)',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onRestart,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, size: 20),
                              SizedBox(width: 8),
                              Text('重新开始'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onReturnHome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home, size: 20),
                              SizedBox(width: 8),
                              Text('返回主页'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}