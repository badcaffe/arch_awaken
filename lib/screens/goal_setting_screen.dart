import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _targetCountControllers = {};
  final Map<String, TextEditingController> _targetSecondsControllers = {};
  final Map<String, TextEditingController> _leftTargetControllers = {};
  final Map<String, TextEditingController> _rightTargetControllers = {};
  final Map<String, TextEditingController> _restIntervalControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with length 0, will be updated in build
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final goalModel = Provider.of<GoalModel>(context);
    final goals = goalModel.goals;

    // Update tab controller length when goals are available
    if (goals.isNotEmpty && _tabController.length != goals.length) {
      _tabController.dispose();
      _tabController = TabController(length: goals.length, vsync: this);
    }

    // Initialize controllers for all goals
    for (final goal in goals) {
      _targetCountControllers.putIfAbsent(goal.exerciseId,
          () => TextEditingController(text: goal.targetCount.toString()));
      _targetSecondsControllers.putIfAbsent(goal.exerciseId,
          () => TextEditingController(text: goal.targetSeconds.toString()));
      _leftTargetControllers.putIfAbsent(goal.exerciseId,
          () => TextEditingController(text: goal.leftTarget.toString()));
      _rightTargetControllers.putIfAbsent(goal.exerciseId,
          () => TextEditingController(text: goal.rightTarget.toString()));
      _restIntervalControllers.putIfAbsent(goal.exerciseId,
          () => TextEditingController(text: goal.restInterval.toString()));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all text controllers
    for (final controller in _targetCountControllers.values) {
      controller.dispose();
    }
    for (final controller in _targetSecondsControllers.values) {
      controller.dispose();
    }
    for (final controller in _leftTargetControllers.values) {
      controller.dispose();
    }
    for (final controller in _rightTargetControllers.values) {
      controller.dispose();
    }
    for (final controller in _restIntervalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalModel = Provider.of<GoalModel>(context);
    final goals = goalModel.goals;

    // Show loading indicator if goals are not loaded yet
    if (goals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('训练目标设置'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练目标设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withAlpha(180),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          tabs: goals.map((goal) => Tab(text: goal.exerciseName)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: goals.map((goal) => _buildExerciseGoalSettings(goal)).toList(),
      ),
    );
  }

  Widget _buildExerciseGoalSettings(ExerciseGoal goal) {
    final goalModel = Provider.of<GoalModel>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Exercise Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.exerciseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getExerciseDescription(goal.exerciseId),
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

        // Save Button
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('目标设置已保存')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '保存目标设置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Target Count
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '目标次数',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getCountDescription(goal.exerciseId),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '目标次数',
                    border: OutlineInputBorder(),
                    suffixText: '次',
                  ),
                  controller: _targetCountControllers[goal.exerciseId],
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? goal.targetCount;
                    goalModel.setTargetCount(goal.exerciseId, count);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Target Duration (for timer-based exercises)
        if (goal.exerciseId == 'frog_pose' || goal.exerciseId == 'stretching')
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '目标时长',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '每次训练的目标持续时间',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '目标时长',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _targetSecondsControllers[goal.exerciseId],
                    onChanged: (value) {
                      final seconds = int.tryParse(value) ?? goal.targetSeconds;
                      goalModel.setTargetSeconds(goal.exerciseId, seconds);
                    },
                  ),
                ],
              ),
            ),
          ),
        if (goal.exerciseId == 'frog_pose' || goal.exerciseId == 'stretching') const SizedBox(height: 16),

        // Left/Right Targets (for yoga_brick_ball_pickup)
        if (goal.hasLeftRight)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '左右侧目标',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '分别设置左右侧的训练目标',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '左侧目标',
                            border: OutlineInputBorder(),
                            suffixText: '次',
                          ),
                          controller: _leftTargetControllers[goal.exerciseId],
                          onChanged: (value) {
                            final leftTarget = int.tryParse(value) ?? goal.leftTarget;
                            goalModel.setLeftRightTargets(goal.exerciseId, leftTarget, goal.rightTarget);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '右侧目标',
                            border: OutlineInputBorder(),
                            suffixText: '次',
                          ),
                          controller: _rightTargetControllers[goal.exerciseId],
                          onChanged: (value) {
                            final rightTarget = int.tryParse(value) ?? goal.rightTarget;
                            goalModel.setLeftRightTargets(goal.exerciseId, goal.leftTarget, rightTarget);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (goal.hasLeftRight) const SizedBox(height: 16),

        // Rest Interval
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '休息间隔',
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
                    labelText: '休息间隔',
                    border: OutlineInputBorder(),
                    suffixText: '秒',
                  ),
                  controller: _restIntervalControllers[goal.exerciseId],
                  onChanged: (value) {
                    final interval = int.tryParse(value) ?? goal.restInterval;
                    goalModel.setRestInterval(goal.exerciseId, interval);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getExerciseDescription(String exerciseId) {
    switch (exerciseId) {
      case 'ball_tiptoe':
        return '使用小球进行踮脚训练，增强足弓力量';
      case 'yoga_brick_tiptoe':
        return '使用瑜伽砖进行踮脚训练，提升平衡能力';
      case 'yoga_brick_ball_pickup':
        return '使用瑜伽砖和球进行捡球训练，锻炼左右侧协调性';
      case 'frog_pose':
        return '青蛙趴姿势训练，拉伸大腿内侧和髋部';
      case 'glute_bridge':
        return '臀桥训练，增强臀部和核心力量';
      case 'stretching':
        return '全身拉伸训练，提高柔韧性和放松肌肉';
      default:
        return '训练项目';
    }
  }

  String _getCountDescription(String exerciseId) {
    switch (exerciseId) {
      case 'ball_tiptoe':
        return '每次踮脚的目标次数';
      case 'yoga_brick_tiptoe':
        return '每次踮脚的目标次数';
      case 'yoga_brick_ball_pickup':
        return '每次捡球的总目标次数';
      case 'frog_pose':
        return '每次保持姿势的持续时间';
      case 'glute_bridge':
        return '每次臀桥的目标次数';
      case 'stretching':
        return '每次拉伸的持续时间';
      default:
        return '目标次数';
    }
  }
}