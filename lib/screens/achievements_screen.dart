import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training_model.dart';
import '../widgets/training_grid_widget.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final records = trainingModel.records;

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 训练总览
            _buildTrainingOverviewCard(context, records),
            const SizedBox(height: 24),

            // 训练记录
            _buildTrainingRecordsSection(context, trainingModel, records),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingOverviewCard(BuildContext context, List<TrainingRecord> records) {
    final groupedRecords = _groupRecordsByDate(records);
    final totalDuration = records.fold<int>(0, (sum, record) => sum + record.duration);
    final totalCount = records.fold<int>(0, (sum, record) => sum + record.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练总览',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOverviewItem(
                      '总训练次数',
                      '$totalCount',
                      Icons.repeat,
                      Colors.blue,
                    ),
                    _buildOverviewItem(
                      '总训练时长',
                      '${(totalDuration / 60).toStringAsFixed(0)}分钟',
                      Icons.timer,
                      Colors.green,
                    ),
                    _buildOverviewItem(
                      '训练天数',
                      '${groupedRecords.length}',
                      Icons.calendar_today,
                      Colors.orange,
                    ),
                    _buildOverviewItem(
                      '连续天数',
                      '${_calculateCurrentStreak(records)}',
                      Icons.local_fire_department,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


  Widget _buildTrainingRecordsSection(
    BuildContext context,
    TrainingModel trainingModel,
    List<TrainingRecord> records,
  ) {
    if (records.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '训练记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '暂无训练记录',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '开始训练后，记录将显示在这里',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Group records by date
    final Map<String, List<TrainingRecord>> groupedRecords = {};
    for (final record in records) {
      final dateKey = '${record.date.year}-${record.date.month}-${record.date.day}';
      if (!groupedRecords.containsKey(dateKey)) {
        groupedRecords[dateKey] = [];
      }
      groupedRecords[dateKey]!.add(record);
    }

    // Sort dates in descending order
    final sortedDates = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 训练日历
        const Text(
          '训练日历 (最近30天)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 355, // Fixed height for the grid (7 rows of 40px + legend)
          child: TrainingGridWidget(daysToShow: 30),
        ),
        const SizedBox(height: 20),

        // 训练历史
        const Text(
          '训练历史',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final dateKey = sortedDates[index];
            final dateRecords = groupedRecords[dateKey]!;
            // Parse the date key safely
            final dateParts = dateKey.split('-');
            final date = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${dateRecords.length} 项训练',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...dateRecords.map((record) {
                      final exercise = trainingModel.getExerciseById(record.exerciseId);
                      if (exercise == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: exercise.color.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                exercise.icon,
                                size: 16,
                                color: exercise.color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              exercise.type == ExerciseType.timer
                                  ? '${record.duration}秒'
                                  : '${record.count}次',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(record.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Map<String, List<TrainingRecord>> _groupRecordsByDate(List<TrainingRecord> records) {
    final Map<String, List<TrainingRecord>> groupedRecords = {};
    for (final record in records) {
      final dateKey = '${record.date.year}-${record.date.month}-${record.date.day}';
      if (!groupedRecords.containsKey(dateKey)) {
        groupedRecords[dateKey] = [];
      }
      groupedRecords[dateKey]!.add(record);
    }
    return groupedRecords;
  }

  int _calculateCurrentStreak(List<TrainingRecord> records) {
    if (records.isEmpty) return 0;

    final groupedRecords = _groupRecordsByDate(records);
    final sortedDates = groupedRecords.keys.toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    int streak = 0;
    DateTime currentDate = today;

    // Check if today has training
    if (sortedDates.contains(todayKey)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    // Check consecutive days
    while (true) {
      final dateKey = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
      if (sortedDates.contains(dateKey)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return '今天';
    } else if (recordDate == yesterday) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}