import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../models/today_exercises_model.dart';

class TrainingPlanScreen extends StatelessWidget {
  const TrainingPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final goalModel = Provider.of<GoalModel>(context);
    final todayExercisesModel = Provider.of<TodayExercisesModel>(context);
    final todayRecords = trainingModel.getTodayRecords();

    // Create training plan from selected exercises in order
    final trainingPlan = todayExercisesModel.selectedExerciseIds.map((exerciseId) {
      final goal = goalModel.getGoal(exerciseId);
      final exercise = trainingModel.getExerciseById(exerciseId);

      // Use goal target or default values
      final target = exercise?.type == ExerciseType.timer
          ? (goal?.targetSeconds ?? 30)
          : (goal?.repsPerSet ?? 10);

      return {
        'exerciseId': exerciseId,
        'target': target,
        'completed': false,
      };
    }).toList();

    // Update completion status based on today's records
    for (var planItem in trainingPlan) {
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
                .fold(0, (a, b) => a + b);
            planItem['completed'] = totalDuration >= target;
          } else {
            // For counter exercises, check if total count meets target
            final totalCount = exerciseRecords
                .map((record) => record.count)
                .fold(0, (a, b) => a + b);
            planItem['completed'] = totalCount >= target;
          }
        }
      }
    }

    final completedCount = trainingPlan
        .where((item) => item['completed'] == true)
        .length;
    final totalCount = trainingPlan.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日训练计划'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/today-exercises-selection');
            },
          ),
        ],
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
              '训练目标',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: trainingPlan.length,
                itemBuilder: (context, index) {
                  final planItem = trainingPlan[index];
                  final exerciseId = planItem['exerciseId'] as String;
                  final target = planItem['target'] as int;
                  final completed = planItem['completed'] as bool;
                  final themeModel = Provider.of<ThemeModel>(context);
                  final goalModel = Provider.of<GoalModel>(context);
                  final baseExercise = trainingModel.getExerciseById(exerciseId);

                  if (baseExercise == null) return const SizedBox.shrink();

                  // Get goal information for sets
                  final goal = goalModel.getGoal(exerciseId);
                  final sets = goal?.sets ?? 3;
                  final totalCount = baseExercise.type == ExerciseType.timer ? target : target * sets;

                  // Create exercise with theme color
                  final exercise = TrainingExercise(
                    id: baseExercise.id,
                    name: baseExercise.name,
                    description: baseExercise.description,
                    type: baseExercise.type,
                    icon: baseExercise.icon,
                    color: themeModel.getExerciseColor(baseExercise.id),
                  );

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
                            ? '目标: $target秒'
                            : '目标: $target次 × $sets',
                      ),
                      trailing: completed
                          ? ElevatedButton(
                              onPressed: () {
                                if (exerciseId == 'foot_ball_rolling') {
                                  context.go('/foot-ball-rolling/$exerciseId');
                                } else if (exercise.type == ExerciseType.timer) {
                                  context.go('/timer/$exerciseId');
                                } else {
                                  context.go('/counter/$exerciseId');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                '重新开始',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (exerciseId == 'foot_ball_rolling') {
                                  context.go('/foot-ball-rolling/$exerciseId');
                                } else if (exercise.type == ExerciseType.timer) {
                                  context.go('/timer/$exerciseId');
                                } else {
                                  context.go('/counter/$exerciseId');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                '开始训练',
                                style: TextStyle(fontSize: 16),
                              ),
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