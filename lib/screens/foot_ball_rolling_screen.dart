import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../services/sound_service.dart';
import 'training_completion_screen.dart';

enum RollingType {
  leftRight,    // 左右滚动
  frontBack,    // 前后滚动
  heel,         // 脚后跟滚动
}

class FootBallRollingScreen extends StatefulWidget {
  final String exerciseId;

  const FootBallRollingScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<FootBallRollingScreen> createState() => _FootBallRollingScreenState();
}

class _FootBallRollingScreenState extends State<FootBallRollingScreen> {
  Timer? _timer;
  int _remainingTime = 60; // 默认60秒
  bool _isRunning = false;
  RollingType _currentRollingType = RollingType.leftRight;
  bool _isLeftFoot = true; // true: 左脚, false: 右脚
  int _totalDuration = 0; // 总训练时长
  Timer? _trainingTimer;


  @override
  void initState() {
    super.initState();
    _loadGoalSettings();

    // Check if we're in sequential training mode and auto-start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trainingModel = Provider.of<TrainingModel>(context, listen: false);
      // Auto-start if sequential mode is enabled
      if (trainingModel.isSequentialMode) {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _trainingTimer?.cancel();
    super.dispose();
  }

  void _loadGoalSettings() {
    final goalModel = Provider.of<GoalModel>(context, listen: false);
    final goal = goalModel.getGoal(widget.exerciseId);
    if (goal != null) {
      setState(() {
        // Use the specific duration for the current rolling type
        _remainingTime = _getDurationForRollingType(goal, _currentRollingType);
      });
    }
  }

  int _getDurationForRollingType(ExerciseGoal goal, RollingType type) {
    switch (type) {
      case RollingType.leftRight:
        return goal.leftRightSeconds;
      case RollingType.frontBack:
        return goal.frontBackSeconds;
      case RollingType.heel:
        return goal.heelSeconds;
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    // 播放训练指令语音
    _playTrainingInstruction();

    // 开始训练总时长计时
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _totalDuration++;
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isRunning = false;
          timer.cancel();
          _trainingTimer?.cancel();
          _nextPhase();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _trainingTimer?.cancel();
  }

  void _stopAllTimers() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _trainingTimer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      // Load the duration for the current rolling type from settings
      final goalModel = Provider.of<GoalModel>(context, listen: false);
      final goal = goalModel.getGoal(widget.exerciseId);
      if (goal != null) {
        _remainingTime = _getDurationForRollingType(goal, _currentRollingType);
      } else {
        _remainingTime = 60; // Fallback to 60 seconds if goal not found
      }
      _currentRollingType = RollingType.leftRight;
      _isLeftFoot = true;
      _totalDuration = 0;
    });
    _timer?.cancel();
    _trainingTimer?.cancel();
  }


  void _playTrainingInstruction() async {
    final soundService = SoundService();
    final footName = _isLeftFoot ? 'left' : 'right';
    final rollingName = _getRollingTypeSoundName(_currentRollingType);
    final soundPath = 'sounds/foot-ball-rolling-$footName-$rollingName.mp3';

    try {
      await soundService.playCustomSound(soundPath);
    } catch (e) {
      // 如果语音文件不存在，静默失败
    }
  }

  String _getRollingTypeSoundName(RollingType type) {
    switch (type) {
      case RollingType.leftRight:
        return 'lr';
      case RollingType.frontBack:
        return 'fb';
      case RollingType.heel:
        return 'heel';
    }
  }

  void _nextPhase() {
    // 检查是否是右脚完成训练
    if (_currentRollingType == RollingType.heel && !_isLeftFoot) {
      // 右脚完成，训练结束
      _stopAllTimers();
      _saveRecord();
      _showCompletionDialog();
      return;
    }

    setState(() {
      switch (_currentRollingType) {
        case RollingType.leftRight:
          _currentRollingType = RollingType.frontBack;
          break;
        case RollingType.frontBack:
          _currentRollingType = RollingType.heel;
          break;
        case RollingType.heel:
          if (_isLeftFoot) {
            // 左脚完成，直接切换到右脚
            _isLeftFoot = false;
            _currentRollingType = RollingType.leftRight;
          }
          break;
      }
      // Load the duration for the new rolling type from settings
      final goalModel = Provider.of<GoalModel>(context, listen: false);
      final goal = goalModel.getGoal(widget.exerciseId);
      if (goal != null) {
        _remainingTime = _getDurationForRollingType(goal, _currentRollingType);
      } else {
        _remainingTime = 60; // Fallback to 60 seconds if goal not found
      }
    });

    // 自动开始下一阶段
    _startTimer();
  }

  void _saveRecord() {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    trainingModel.addRecord(
      TrainingRecord(
        exerciseId: widget.exerciseId,
        date: DateTime.now(),
        duration: _totalDuration,
        count: 1, // 完成一次完整训练
      ),
    );
  }

  void _showCompletionDialog() {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);

    // Check if we're in sequential training mode and get next exercise
    String? nextExerciseId;
    if (trainingModel.isSequentialTrainingActive) {
      nextExerciseId = trainingModel.getNextSequentialExercise();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TrainingCompletionScreen(
          exerciseId: widget.exerciseId,
          count: 1, // 完成一次完整训练
          duration: _totalDuration,
          sets: 1, // 脚底滚球训练为1组完整训练
          repsPerSet: 6, // 左右脚各3个动作
          onRestart: () {
            Navigator.of(context).pop();
            _resetTimer();
          },
          onReturnHome: () {
            Navigator.of(context).pop();
            // Clear sequential mode when returning to home
            trainingModel.clearSequentialMode();
            context.go('/');
          },
          onNextTraining: nextExerciseId != null ? () {
            Navigator.of(context).pop();
            _startNextTraining(nextExerciseId!, trainingModel);
            // 延迟移动到下一个练习，确保新页面能正确获取当前练习ID
            WidgetsBinding.instance.addPostFrameCallback((_) {
              trainingModel.moveToNextSequentialExercise();
            });
          } : null,
        );
      },
    );
  }

  void _startNextTraining(String nextExerciseId, TrainingModel trainingModel) {
    final nextExercise = trainingModel.getExerciseById(nextExerciseId);

    if (nextExercise != null) {
      if (nextExerciseId == 'foot_ball_rolling') {
        context.go('/foot-ball-rolling/$nextExerciseId');
      } else if (nextExercise.type == ExerciseType.timer) {
        // 青蛙趴和拉伸使用组计时器，其他计时训练使用简单计时器
        if (nextExerciseId == 'frog_pose' || nextExerciseId == 'stretching') {
          context.go('/group-timer/$nextExerciseId');
        } else {
          context.go('/timer/$nextExerciseId');
        }
      } else {
        context.go('/counter/$nextExerciseId');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final exercise = trainingModel.getExerciseById(widget.exerciseId);

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('脚底滚球训练'),
        ),
        body: const Center(
          child: Text('训练项目未找到'),
        ),
      );
    }

    final exerciseColor = themeModel.getExerciseColor(widget.exerciseId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('脚底滚球训练'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Clear sequential mode when back button is pressed
            trainingModel.clearSequentialMode();
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          // 可滚动的内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // 状态指示器
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: exerciseColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: exerciseColor, width: 2),
                      ),
                      child: Text(
                        _isRunning ? '训练中' : '准备开始',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: exerciseColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 进度指示器
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isCurrent = index == _currentRollingType.index;
                        final isCompleted = index < _currentRollingType.index;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green
                                : isCurrent
                                    ? exerciseColor
                                    : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // 计时器显示
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: exerciseColor.withAlpha(25),
                        border: Border.all(
                          color: exerciseColor,
                          width: 4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_remainingTime',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: exerciseColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '秒',
                            style: TextStyle(
                              fontSize: 16,
                              color: exerciseColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // 底部固定的控制按钮区域
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isRunning)
                  IconButton(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      iconSize: 32,
                    ),
                  )
                else
                  IconButton(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      iconSize: 32,
                    ),
                  ),

                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    iconSize: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}