import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal_model.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showInstantEffectTip = true;
  final Map<String, TextEditingController> _targetCountControllers = {};
  final Map<String, TextEditingController> _targetSecondsControllers = {};
  final Map<String, TextEditingController> _leftTargetControllers = {};
  final Map<String, TextEditingController> _rightTargetControllers = {};
  final Map<String, TextEditingController> _restIntervalControllers = {};
  final Map<String, TextEditingController> _setsControllers = {};
  final Map<String, TextEditingController> _countIntervalControllers = {};
  final Map<String, TextEditingController> _prepareIntervalControllers = {};
  final Map<String, TextEditingController> _leftRightSecondsControllers = {};
  final Map<String, TextEditingController> _frontBackSecondsControllers = {};
  final Map<String, TextEditingController> _heelSecondsControllers = {};
  final Map<String, TextEditingController> _longPressDurationControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with length 0, will be updated in build
    _tabController = TabController(length: 0, vsync: this);
    _loadInstantEffectTipStatus();
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
      // For foot_ball_rolling, only initialize rolling type duration controllers
      if (goal.exerciseId == 'foot_ball_rolling') {
        _leftRightSecondsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.leftRightSeconds.toString()));
        _frontBackSecondsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.frontBackSeconds.toString()));
        _heelSecondsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.heelSeconds.toString()));
      } else {
        // For other exercises, initialize all controllers
        _targetCountControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.repsPerSet.toString()));
        _targetSecondsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.targetSeconds.toString()));
        _leftTargetControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.leftTarget.toString()));
        _rightTargetControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.rightTarget.toString()));
        _restIntervalControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.restInterval.toString()));
        _setsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.sets.toString()));
        _countIntervalControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.countInterval.toString()));
        _prepareIntervalControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.prepareInterval.toString()));
        _leftRightSecondsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.leftRightSeconds.toString()));
        _frontBackSecondsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.frontBackSeconds.toString()));
        _heelSecondsControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.heelSeconds.toString()));
        _longPressDurationControllers.putIfAbsent(goal.exerciseId,
            () => TextEditingController(text: goal.longPressDuration.toString()));
      }
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
    for (final controller in _setsControllers.values) {
      controller.dispose();
    }
    for (final controller in _countIntervalControllers.values) {
      controller.dispose();
    }
    for (final controller in _prepareIntervalControllers.values) {
      controller.dispose();
    }
    for (final controller in _leftRightSecondsControllers.values) {
      controller.dispose();
    }
    for (final controller in _frontBackSecondsControllers.values) {
      controller.dispose();
    }
    for (final controller in _heelSecondsControllers.values) {
      controller.dispose();
    }
    for (final controller in _longPressDurationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInstantEffectTipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showInstantEffectTip = prefs.getBool('show_instant_effect_tip') ?? true;
    });
  }

  Future<void> _saveInstantEffectTipStatus(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_instant_effect_tip', show);
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
      body: Column(
        children: [
          // 改动即时生效提示
          if (_showInstantEffectTip) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '改动即时生效',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 18,
                    ),
                    onPressed: () async {
                      await _saveInstantEffectTipStatus(false);
                      setState(() {
                        _showInstantEffectTip = false;
                      });
                    },
                    tooltip: '关闭提示',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 设置内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: goals.map((goal) => _buildExerciseGoalSettings(goal)).toList(),
            ),
          ),
        ],
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
          margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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

        // Training Sets (for all exercises except foot_ball_rolling)
        if (goal.exerciseId != 'foot_ball_rolling')
          Card(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '训练组数',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '每次训练要完成的组数',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '训练组数',
                      border: OutlineInputBorder(),
                      suffixText: '组',
                    ),
                    controller: _setsControllers[goal.exerciseId],
                    onChanged: (value) {
                      final sets = int.tryParse(value) ?? goal.sets;
                      goalModel.setSets(goal.exerciseId, sets);
                    },
                  ),
                ],
              ),
            ),
          ),

        // Duration Per Set (for frog_pose and stretching)
        if (goal.exerciseId == 'frog_pose' || goal.exerciseId == 'stretching')
          Card(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '每组时长',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '每组训练的持续时间',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '每组时长',
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

        // Reps Per Set (for counter-based exercises only)
        if (goal.exerciseId == 'ball_tiptoe' ||
            goal.exerciseId == 'yoga_brick_tiptoe' ||
            goal.exerciseId == 'yoga_brick_ball_pickup' ||
            goal.exerciseId == 'glute_bridge')
          Card(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '每组次数',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '每组训练要完成的次数',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '每组次数',
                      border: OutlineInputBorder(),
                      suffixText: '次',
                    ),
                    controller: _targetCountControllers[goal.exerciseId],
                    onChanged: (value) {
                      final repsPerSet = int.tryParse(value) ?? goal.repsPerSet;
                      goalModel.setRepsPerSet(goal.exerciseId, repsPerSet);
                    },
                  ),
                ],
              ),
            ),
          ),

        // Rest Interval (for all exercises except foot_ball_rolling)
        if (goal.exerciseId != 'foot_ball_rolling')
          Card(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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

        // Count Interval (for all exercises except foot_ball_rolling)
        if (goal.exerciseId != 'foot_ball_rolling')
          Card(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '计数阶段时长',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.exerciseId == 'frog_pose' || goal.exerciseId == 'stretching'
                        ? '计时训练中每个阶段的持续时间'
                        : '计数训练中每个阶段的持续时间',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '计数阶段时长',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _countIntervalControllers[goal.exerciseId],
                    onChanged: (value) {
                      final interval = int.tryParse(value) ?? goal.countInterval;
                      goalModel.setCountInterval(goal.exerciseId, interval);
                    },
                  ),
                ],
              ),
            ),
          ),

        // Prepare Interval (for all exercises except foot_ball_rolling)
        if (goal.exerciseId != 'foot_ball_rolling')
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '准备阶段时长',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.exerciseId == 'frog_pose' || goal.exerciseId == 'stretching'
                        ? '计时训练中每个阶段的持续时间'
                        : '计数训练中每个阶段的持续时间',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '准备阶段时长',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _prepareIntervalControllers[goal.exerciseId],
                    onChanged: (value) {
                      final interval = int.tryParse(value) ?? goal.prepareInterval;
                      goalModel.setPrepareInterval(goal.exerciseId, interval);
                    },
                  ),
                ],
              ),
            ),
          ),
        // Left/Right Targets (for yoga_brick_ball_pickup)
        if (goal.hasLeftRight && goal.exerciseId != 'foot_ball_rolling')
          Card(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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
        if (goal.hasLeftRight && goal.exerciseId != 'foot_ball_rolling')
          const SizedBox(height: 16),

        // Count Mode Settings (for yoga_brick_ball_pickup only)
        if (goal.exerciseId == 'yoga_brick_ball_pickup')
          Card(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '计次模式设置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '选择短按立即计次，或长按确认后计次',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Count Mode Selection
                  Row(
                    children: [
                      const Text('计次模式: '),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'tap',
                              label: Text('短按'),
                              icon: Icon(Icons.touch_app),
                            ),
                            ButtonSegment(
                              value: 'longPress',
                              label: Text('长按'),
                              icon: Icon(Icons.touch_app_outlined),
                            ),
                          ],
                          selected: {goal.countMode},
                          onSelectionChanged: (Set<String> selected) {
                            goalModel.setCountMode(goal.exerciseId, selected.first);
                          },
                        ),
                      ),
                    ],
                  ),
                  // Long Press Duration (only show in long press mode)
                  if (goal.countMode == 'longPress') ...[
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '长按确认时长',
                        border: OutlineInputBorder(),
                        suffixText: '秒',
                        helperText: '长按超过此时长后计次加一',
                      ),
                      controller: _longPressDurationControllers[goal.exerciseId],
                      onChanged: (value) {
                        final duration = int.tryParse(value) ?? goal.longPressDuration;
                        goalModel.setLongPressDuration(goal.exerciseId, duration);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

        // Add spacing before foot_ball_rolling card
        if (goal.exerciseId == 'foot_ball_rolling')
          const SizedBox(height: 16),

        // Rolling Type Durations (for foot_ball_rolling)
        if (goal.exerciseId == 'foot_ball_rolling')
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '滚动类型时长设置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '设置各滚动类型的训练时长',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Left/Right Rolling
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '左右滚动时长',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _leftRightSecondsControllers[goal.exerciseId],
                    onChanged: (value) {
                      final leftRightSeconds = int.tryParse(value) ?? goal.leftRightSeconds;
                      goalModel.setRollingTypeDurations(goal.exerciseId, leftRightSeconds, goal.frontBackSeconds, goal.heelSeconds);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Front/Back Rolling
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '前后滚动时长',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _frontBackSecondsControllers[goal.exerciseId],
                    onChanged: (value) {
                      final frontBackSeconds = int.tryParse(value) ?? goal.frontBackSeconds;
                      goalModel.setRollingTypeDurations(goal.exerciseId, goal.leftRightSeconds, frontBackSeconds, goal.heelSeconds);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Heel Rolling
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '脚后跟滚动时长',
                      border: OutlineInputBorder(),
                      suffixText: '秒',
                    ),
                    controller: _heelSecondsControllers[goal.exerciseId],
                    onChanged: (value) {
                      final heelSeconds = int.tryParse(value) ?? goal.heelSeconds;
                      goalModel.setRollingTypeDurations(goal.exerciseId, goal.leftRightSeconds, goal.frontBackSeconds, heelSeconds);
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
      case 'foot_ball_rolling':
        return '使用小球进行脚底滚动训练，设置各滚动类型的训练时长';
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
}