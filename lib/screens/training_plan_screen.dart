import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';

class TrainingPlanScreen extends StatelessWidget {
  const TrainingPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final todayRecords = trainingModel.getTodayRecords();

    // Create a default training plan
    final defaultPlan = [
      {'exerciseId': 'ball_tiptoe', 'target': 20, 'completed': false},
      {'exerciseId': 'yoga_brick_tiptoe', 'target': 15, 'completed': false},
      {'exerciseId': 'yoga_brick_ball_pickup', 'target': 15, 'completed': false},
      {'exerciseId': 'frog_pose', 'target': 60, 'completed': false}, // 60 seconds
      {'exerciseId': 'glute_bridge', 'target': 15, 'completed': false},
      {'exerciseId': 'stretching', 'target': 120, 'completed': false}, // 120 seconds
    ];

    // Update completion status based on today's records
    for (var planItem in defaultPlan) {
      final exerciseId = planItem['exerciseId'] as String;
      final target = planItem['target'] as int;
      final exerciseRecords = todayRecords
          .where((record) => record.exerciseId == exerciseId)
          .toList();

      if (exerciseRecords.isNotEmpty) {
        final exercise = trainingModel.getExerciseById(exerciseId);
        if (exercise != null) {
          if (exercise.type == ExerciseType.timer) {
            // For timer exercises, check if total duration meets target
            final totalDuration = exerciseRecords
                .map((record) => record.duration)
                .reduce((a, b) => a + b);
            planItem['completed'] = totalDuration >= target;
          } else {
            // For counter exercises, check if total count meets target
            final totalCount = exerciseRecords
                .map((record) => record.count)
                .reduce((a, b) => a + b);
            planItem['completed'] = totalCount >= target;
          }
        }
      }
    }

    final completedCount = defaultPlan
        .where((item) => item['completed'] == true)
        .length;
    final totalCount = defaultPlan.length;
    final progress = completedCount / totalCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日训练计划'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日进度',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount/$totalCount 项已完成',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '训练项目',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: defaultPlan.length,
                itemBuilder: (context, index) {
                  final planItem = defaultPlan[index];
                  final exerciseId = planItem['exerciseId'] as String;
                  final target = planItem['target'] as int;
                  final completed = planItem['completed'] as bool;
                  final exercise = trainingModel.getExerciseById(exerciseId);

                  if (exercise == null) return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: exercise.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          exercise.icon,
                          color: exercise.color,
                        ),
                      ),
                      title: Text(exercise.name),
                      subtitle: Text(
                        exercise.type == ExerciseType.timer
                            ? '目标: ${target}秒'
                            : '目标: ${target}次',
                      ),
                      trailing: completed
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '已完成',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (exercise.type == ExerciseType.timer) {
                                  context.go('/timer/$exerciseId');
                                } else {
                                  context.go('/counter/$exerciseId');
                                }
                              },
                              child: const Text('开始训练'),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}