import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';

class SequentialTrainingCompletionDialog extends StatefulWidget {
  final String currentExerciseId;
  final String nextExerciseId;
  final int intervalSeconds;
  final VoidCallback onContinue;
  final VoidCallback onStop;

  const SequentialTrainingCompletionDialog({
    super.key,
    required this.currentExerciseId,
    required this.nextExerciseId,
    required this.intervalSeconds,
    required this.onContinue,
    required this.onStop,
  });

  @override
  State<SequentialTrainingCompletionDialog> createState() => _SequentialTrainingCompletionDialogState();
}

class _SequentialTrainingCompletionDialogState extends State<SequentialTrainingCompletionDialog> {
  late int _remainingSeconds;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.intervalSeconds;
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
          widget.onContinue();
        }
      });
    });
  }

  void _continueNow() {
    _timer.cancel();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final currentExercise = trainingModel.getExerciseById(widget.currentExerciseId);
    final nextExercise = trainingModel.getExerciseById(widget.nextExerciseId);

    if (currentExercise == null || nextExercise == null) {
      return AlertDialog(
        title: const Text('错误'),
        content: const Text('训练项目不存在'),
        actions: [
          TextButton(
            onPressed: widget.onStop,
            child: const Text('确定'),
          ),
        ],
      );
    }

    final currentExerciseColor = themeModel.getExerciseColor(widget.currentExerciseId);
    final nextExerciseColor = themeModel.getExerciseColor(widget.nextExerciseId);

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
                color: currentExerciseColor.withAlpha(25),
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
                        color: currentExerciseColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: currentExerciseColor.withAlpha(128),
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
                        color: currentExerciseColor,
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
                          color: currentExerciseColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          currentExercise.icon,
                          color: currentExerciseColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentExercise.name,
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

                  // Next exercise info
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

                  // Countdown and continue button
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
                            onPressed: _continueNow,
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

                  // Stop training button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onStop,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '停止训练',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
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