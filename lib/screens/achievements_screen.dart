import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training_model.dart';
import 'training_records_screen.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Training Records Summary Card
              _buildTrainingRecordsSummaryCard(context, records),
              const SizedBox(height: 24),

              // Quick Access to Training Records
              _buildTrainingRecordsAccessCard(context),
              const SizedBox(height: 24),

              // Achievements Section
              _buildAchievementsSection(context),
              const SizedBox(height: 24),

              // Progress Stats
              _buildProgressStatsCard(context, records),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingRecordsSummaryCard(BuildContext context, List<TrainingRecord> records) {
    final groupedRecords = _groupRecordsByDate(records);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  '总训练次数',
                  '${records.length}',
                  Icons.fitness_center,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  '训练天数',
                  '${groupedRecords.length}',
                  Icons.calendar_today,
                  Colors.green,
                ),
                _buildSummaryItem(
                  '连续天数',
                  '${_calculateCurrentStreak(records)}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingRecordsAccessCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            const Text(
              '查看详细的历史训练数据和进度统计',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TrainingRecordsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('查看完整训练记录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '成就徽章',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildAchievementBadge(
              context,
              '7天坚持',
              Icons.emoji_events,
              Colors.amber,
              '连续训练7天',
              trainingModel.hasAchievement('7_day_streak'),
            ),
            _buildAchievementBadge(
              context,
              '新手入门',
              Icons.star,
              Colors.blue,
              '完成第一周训练',
              trainingModel.hasAchievement('first_week'),
            ),
            _buildAchievementBadge(
              context,
              '足弓觉醒',
              Icons.favorite,
              Colors.red,
              '完成一个月训练',
              trainingModel.hasAchievement('arch_awakening'),
            ),
            _buildAchievementBadge(
              context,
              '夹球专家',
              Icons.sports_baseball,
              Colors.green,
              '完成100次夹球踮脚',
              trainingModel.hasAchievement('ball_tiptoe_expert'),
            ),
            _buildAchievementBadge(
              context,
              '瑜伽大师',
              Icons.self_improvement,
              Colors.purple,
              '完成所有瑜伽砖训练',
              trainingModel.hasAchievement('yoga_master'),
            ),
            _buildAchievementBadge(
              context,
              '拉伸达人',
              Icons.accessibility,
              Colors.orange,
              '累计拉伸60分钟',
              trainingModel.hasAchievement('stretching_expert'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    bool unlocked,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: unlocked ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: unlocked ? color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: unlocked ? color : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStatsCard(BuildContext context, List<TrainingRecord> records) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final totalDuration = records.fold<int>(0, (sum, record) => sum + record.duration);
    final totalCount = records.fold<int>(0, (sum, record) => sum + record.count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '进度统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(
                  '总训练时长',
                  '${(totalDuration / 60).toStringAsFixed(1)}分钟',
                  Icons.timer,
                  Colors.purple,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  '总训练次数',
                  '$totalCount次',
                  Icons.repeat,
                  Colors.teal,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  '成就解锁',
                  '${_calculateUnlockedAchievements(trainingModel)}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '您已经坚持训练 ${_calculateCurrentStreak(records)} 天',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
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
      ),
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

  int _calculateUnlockedAchievements(TrainingModel trainingModel) {
    // Simple calculation based on records count
    final records = trainingModel.records;
    if (records.isEmpty) return 0;

    final totalRecords = records.length;
    if (totalRecords >= 30) return 6;
    if (totalRecords >= 20) return 5;
    if (totalRecords >= 15) return 4;
    if (totalRecords >= 10) return 3;
    if (totalRecords >= 5) return 2;
    if (totalRecords >= 1) return 1;
    return 0;
  }
}