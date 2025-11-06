import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';

class ProjectSettingsScreen extends StatefulWidget {
  const ProjectSettingsScreen({super.key});

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  late TextEditingController _globalRestIntervalController;
  late TextEditingController _globalTrainingIntervalController;

  @override
  void initState() {
    super.initState();
    final goalModel = Provider.of<GoalModel>(context, listen: false);
    final firstGoal = goalModel.goals.isNotEmpty ? goalModel.goals.first : null;

    // 使用第一个项目的设置作为全局设置的默认值
    _globalRestIntervalController = TextEditingController(
      text: (firstGoal?.restInterval ?? 10).toString(),
    );
    _globalTrainingIntervalController = TextEditingController(
      text: (firstGoal?.trainingInterval ?? 30).toString(),
    );
  }

  @override
  void dispose() {
    _globalRestIntervalController.dispose();
    _globalTrainingIntervalController.dispose();
    super.dispose();
  }

  void _applyGlobalSettings() {
    final goalModel = Provider.of<GoalModel>(context, listen: false);

    final restInterval = int.tryParse(_globalRestIntervalController.text) ?? 10;
    final trainingInterval = int.tryParse(_globalTrainingIntervalController.text) ?? 30;

    // 应用到所有项目
    for (final goal in goalModel.goals) {
      goalModel.setRestInterval(goal.exerciseId, restInterval);
      goalModel.setTrainingInterval(goal.exerciseId, trainingInterval);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('项目设置已保存并应用到所有项目')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 说明卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '通用项目设置',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '这些设置将应用到所有训练项目，包括休息时长、项目间隔等通用参数。',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 组间休息时间设置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '组间休息时间',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '每组训练之间的休息时间',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '组间休息时间',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _globalRestIntervalController,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 训练项目间隔设置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '项目间休息时间',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '按顺序训练时，不同项目之间的休息时间',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '项目间休息时间',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _globalTrainingIntervalController,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 保存按钮
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyGlobalSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '保存设置并应用到所有项目',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}