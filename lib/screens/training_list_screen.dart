import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';

class TrainingListScreen extends StatelessWidget {
  const TrainingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final exercises = trainingModel.getExercisesWithTheme(themeModel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练项目'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _buildExerciseCard(context, exercise);
          },
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, TrainingExercise exercise) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (exercise.type == ExerciseType.timer) {
            context.go('/timer/${exercise.id}');
          } else {
            context.go('/counter/${exercise.id}');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: exercise.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exercise.icon,
                  size: 36,
                  color: exercise.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: exercise.type == ExerciseType.timer
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.type == ExerciseType.timer ? '计时' : '计次',
                  style: TextStyle(
                    fontSize: 10,
                    color: exercise.type == ExerciseType.timer
                        ? Colors.blue
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}