import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart' hide AppTheme;
import '../models/goal_model.dart';
import '../models/today_exercises_model.dart';
import '../theme/app_theme.dart';

class TrainingPlanScreen extends StatefulWidget {
  const TrainingPlanScreen({super.key});

  @override
  State<TrainingPlanScreen> createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  void _startSequentialTraining(BuildContext context, List<Map<String, dynamic>> trainingPlan) {
    if (trainingPlan.isEmpty) return;

    final trainingModel = Provider.of<TrainingModel>(context, listen: false);

    // 提取训练项目ID列表
    final exerciseIds = trainingPlan.map((item) => item['exerciseId'] as String).toList();

    // 启动顺序训练
    trainingModel.startSequentialTraining(exerciseIds);

    // 获取第一个训练项目
    final firstExerciseId = trainingModel.getCurrentSequentialExercise();
    if (firstExerciseId != null) {
      final firstExerciseObj = trainingModel.getExerciseById(firstExerciseId);
      if (firstExerciseObj != null) {
        // 直接开始第一个训练项目
        if (firstExerciseId == 'foot_ball_rolling') {
          context.go('/foot-ball-rolling/$firstExerciseId');
        } else if (firstExerciseObj.type == ExerciseType.timer) {
          // 青蛙趴和拉伸使用组计时器，其他计时训练使用简单计时器
          if (firstExerciseId == 'frog_pose' || firstExerciseId == 'stretching') {
            context.go('/group-timer/$firstExerciseId');
          } else {
            context.go('/timer/$firstExerciseId');
          }
        } else {
          context.go('/counter/$firstExerciseId');
        }
      }
    }
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 进度卡片
            Container(
              decoration: AppTheme.cardDecoration(context),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日进度',
                      style: AppTheme.headlineSmall(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    AppTheme.progressIndicator(value: progress, context: context),
                    const SizedBox(height: 8.0),
                    Text(
                      '$completedCount/$totalCount 项已完成',
                      style: AppTheme.bodyMedium(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // 按顺序开始所有训练项目的按钮
            if (trainingPlan.isNotEmpty)
              Container(
                decoration: AppTheme.cardDecoration(context),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '完整训练流程',
                        style: AppTheme.headlineSmall(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '按顺序完成所有$totalCount个训练项目，每个项目之间自动间隔休息',
                        style: AppTheme.bodyMedium(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _startSequentialTraining(context, trainingPlan);
                            final trainingModel = Provider.of<TrainingModel>(context, listen: false);
                            final todayExercisesModel = Provider.of<TodayExercisesModel>(context, listen: false);

                            // Set sequential mode and start training
                            trainingModel.setSequentialMode(true);
                            trainingModel.startSequentialTraining(todayExercisesModel.selectedExerciseIds);

                            // Navigate to first exercise
                            if (todayExercisesModel.selectedExerciseIds.isNotEmpty) {
                              final firstExerciseId = todayExercisesModel.selectedExerciseIds.first;
                              final exercise = trainingModel.getExerciseById(firstExerciseId);

                              if (exercise != null) {
                                if (firstExerciseId == 'foot_ball_rolling') {
                                  context.go('/foot-ball-rolling/$firstExerciseId');
                                } else if (exercise.type == ExerciseType.timer) {
                                  if (firstExerciseId == 'frog_pose' || firstExerciseId == 'stretching') {
                                    context.go('/group-timer/$firstExerciseId');
                                  } else {
                                    context.go('/timer/$firstExerciseId');
                                  }
                                } else {
                                  context.go('/counter/$firstExerciseId');
                                }
                              }
                            }
                          },
                          style: AppTheme.primaryButtonStyle(context),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8.0),
                              Text(
                                '按顺序开始所有训练',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24.0),
            Text(
              '训练目标',
              style: AppTheme.headlineSmall(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16.0),
            // 使用 Column 替代 ListView.builder，配合 SingleChildScrollView 实现全页滚动
            ...trainingPlan.map((planItem) {
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

              // Create exercise with theme color
              final exercise = TrainingExercise(
                id: baseExercise.id,
                name: baseExercise.name,
                description: baseExercise.description,
                type: baseExercise.type,
                icon: baseExercise.icon,
                color: themeModel.getExerciseColor(baseExercise.id),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: AppTheme.cardDecoration(context),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: exercise.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      exercise.icon,
                      color: exercise.color,
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: AppTheme.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    exercise.type == ExerciseType.timer
                        ? '目标: $target秒'
                        : '目标: $target次 × $sets',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: completed
                      ? ElevatedButton(
                          onPressed: () {
                            if (exerciseId == 'foot_ball_rolling') {
                              context.go('/foot-ball-rolling/$exerciseId');
                            } else if (exercise.type == ExerciseType.timer) {
                              // 青蛙趴和拉伸使用组计时器，其他计时训练使用简单计时器
                              if (exerciseId == 'frog_pose' || exerciseId == 'stretching') {
                                context.go('/group-timer/$exerciseId');
                              } else {
                                context.go('/timer/$exerciseId');
                              }
                            } else {
                              context.go('/counter/$exerciseId');
                            }
                          },
                          style: AppTheme.secondaryButtonStyle(context),
                          child: const Text(
                            '重新开始',
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (exerciseId == 'foot_ball_rolling') {
                              context.go('/foot-ball-rolling/$exerciseId');
                            } else if (exercise.type == ExerciseType.timer) {
                              // 青蛙趴和拉伸使用组计时器，其他计时训练使用简单计时器
                              if (exerciseId == 'frog_pose' || exerciseId == 'stretching') {
                                context.go('/group-timer/$exerciseId');
                              } else {
                                context.go('/timer/$exerciseId');
                              }
                            } else {
                              context.go('/counter/$exerciseId');
                            }
                          },
                          style: AppTheme.primaryButtonStyle(context),
                          child: const Text(
                            '开始训练',
                          ),
                        ),
                ),
              );
            }),
            // 添加底部间距，确保最后一个项目不会被底部导航栏遮挡
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}