import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/today_exercises_model.dart';
import '../models/theme_model.dart';

class TodayExercisesSelectionScreen extends StatelessWidget {
  const TodayExercisesSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final todayExercisesModel = Provider.of<TodayExercisesModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);

    final allExercises = trainingModel.exercises;
    final selectedExerciseIds = todayExercisesModel.selectedExerciseIds;

    // Create a list with selected exercises in order, followed by unselected exercises
    final List<TrainingExercise> displayExercises = [];

    // Add selected exercises in their current order
    for (final exerciseId in selectedExerciseIds) {
      final exercise = allExercises.firstWhere((e) => e.id == exerciseId);
      displayExercises.add(exercise);
    }

    // Add unselected exercises
    for (final exercise in allExercises) {
      if (!selectedExerciseIds.contains(exercise.id)) {
        displayExercises.add(exercise);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日训练项目'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'select_all':
                  todayExercisesModel.selectAll(
                      allExercises.map((e) => e.id).toList());
                  break;
                case 'deselect_all':
                  todayExercisesModel.deselectAll();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'select_all',
                child: Text('全选'),
              ),
              const PopupMenuItem<String>(
                value: 'deselect_all',
                child: Text('全不选'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择今日训练项目',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '长按并拖动已选项目可以调整顺序',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Exercise list
          Expanded(
            child: ReorderableListView.builder(
              itemCount: displayExercises.length,
              itemBuilder: (context, index) {
                final exercise = displayExercises[index];
                final isSelected = selectedExerciseIds.contains(exercise.id);

                final cardContent = Card(
                  key: Key(exercise.id),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeModel.getExerciseColor(exercise.id).withOpacity(0.1)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        exercise.icon,
                        color: isSelected
                            ? themeModel.getExerciseColor(exercise.id)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Text(
                      exercise.description,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show drag handle only for selected exercises
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.drag_handle,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            todayExercisesModel.toggleExercise(exercise.id);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      todayExercisesModel.toggleExercise(exercise.id);
                    },
                  ),
                );

                // Only wrap selected exercises with ReorderableDelayedDragStartListener
                if (isSelected) {
                  return ReorderableDelayedDragStartListener(
                    key: Key(exercise.id),
                    index: index,
                    child: cardContent,
                  );
                } else {
                  return cardContent;
                }
              },
              onReorder: (oldIndex, newIndex) {
                // Get the exercise being moved
                final movedExercise = displayExercises[oldIndex];
                final movedExerciseId = movedExercise.id;

                // Only allow reordering of selected exercises
                if (!selectedExerciseIds.contains(movedExerciseId)) return;

                // Find the current position in the selected list
                final oldSelectedIndex = selectedExerciseIds.indexOf(movedExerciseId);

                // Calculate the new position in the selected list
                int newSelectedIndex = 0;
                int selectedCountBeforeNewIndex = 0;

                for (int i = 0; i < newIndex && i < displayExercises.length; i++) {
                  if (selectedExerciseIds.contains(displayExercises[i].id)) {
                    selectedCountBeforeNewIndex++;
                  }
                }

                newSelectedIndex = selectedCountBeforeNewIndex;

                // Call the reorder method
                todayExercisesModel.reorderExercises(oldSelectedIndex, newSelectedIndex);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pop();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.check),
      ),
    );
  }
}