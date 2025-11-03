import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training_model.dart';

class TrainingGridWidget extends StatefulWidget {
  final int daysToShow;

  const TrainingGridWidget({
    super.key,
    this.daysToShow = 30,
  });

  @override
  State<TrainingGridWidget> createState() => _TrainingGridWidgetState();
}

class _TrainingGridWidgetState extends State<TrainingGridWidget> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to the rightmost position (today) after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    if (_horizontalScrollController.hasClients) {
      // Calculate the maximum scroll extent
      final maxScrollExtent = _horizontalScrollController.position.maxScrollExtent;
      // Scroll to the end to show today with a small delay to ensure layout is complete
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_horizontalScrollController.hasClients) {
          _horizontalScrollController.jumpTo(maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final records = trainingModel.records;
    final exercises = trainingModel.exercises;

    // Calculate date range
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: widget.daysToShow - 1));

    // Generate list of dates in the range
    final List<DateTime> dates = [];
    for (int i = 0; i < widget.daysToShow; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    // Create a map for quick lookup of completed exercises by date
    final Map<String, Set<String>> completedExercisesByDate = {};
    for (final record in records) {
      final dateKey = _getDateKey(record.date);
      final date = DateTime.parse('$dateKey 00:00:00');

      // Only include records within our date range
      if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)))) {
        if (!completedExercisesByDate.containsKey(dateKey)) {
          completedExercisesByDate[dateKey] = {};
        }
        completedExercisesByDate[dateKey]!.add(record.exerciseId);
      }
    }

    return Column(
      children: [
        // Main grid container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                // Fixed left section (training item names)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 120, // Fixed width for exercise names
                  child: Column(
                    children: [
                      // Header cell for fixed section
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: const Text(
                          '训练项目',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // Fixed exercise name cells - use ListView to handle overflow
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey.shade300),
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: exercise.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      exercise.name,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable right section (dates and status)
                Positioned(
                  left: 120, // Start after fixed section
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row (dates)
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: dates.map((date) {
                              final isToday = _isSameDay(date, DateTime.now());

                              return Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade300),
                                    bottom: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  color: isToday ? const Color(0xFF00695C).withAlpha(25) : Colors.transparent,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        color: isToday ? const Color(0xFF00695C) : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _getMonthAbbreviation(date.month),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isToday ? const Color(0xFF00695C) : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Exercise status rows
                        ...exercises.map((exercise) {
                          return SizedBox(
                            height: 40,
                            child: Row(
                              children: dates.map((date) {
                                final dateKey = _getDateKey(date);
                                final isCompleted = completedExercisesByDate[dateKey]?.contains(exercise.id) ?? false;
                                final isToday = _isSameDay(date, DateTime.now());

                                return Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Colors.grey.shade300),
                                      bottom: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    color: isCompleted
                                        ? Colors.green
                                        : (isToday ? Colors.white : Colors.grey.shade100),
                                  ),
                                  child: isCompleted
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                );
                              }).toList(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Legend
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                color: Colors.grey.shade100,
                margin: const EdgeInsets.only(right: 4),
              ),
              const Text(
                '未完成',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              Container(
                width: 16,
                height: 16,
                color: Colors.green,
                margin: const EdgeInsets.only(right: 4),
              ),
              const Text(
                '已完成',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthAbbreviation(int month) {
    final months = ['', '1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    return months[month];
  }

}