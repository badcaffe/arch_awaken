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
            childAspectRatio: 0.9,
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.go('/training-introduction/${exercise.id}');
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: exercise.color.withAlpha(30),
        highlightColor: exercise.color.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: exercise.color.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exercise.icon,
                  size: 32,
                  color: exercise.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
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
                      ? Colors.blue.withAlpha(15)
                      : Colors.green.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  exercise.type == ExerciseType.timer ? '计时' : '计次',
                  style: TextStyle(
                    fontSize: 10,
                    color: exercise.type == ExerciseType.timer
                        ? Colors.blue
                        : Colors.green,
                    fontWeight: FontWeight.w500,
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