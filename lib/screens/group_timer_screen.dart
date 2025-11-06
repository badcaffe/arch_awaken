import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../services/sound_service.dart';
import 'training_completion_screen.dart';

class GroupTimerScreen extends StatefulWidget {
  final String exerciseId;

  const GroupTimerScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<GroupTimerScreen> createState() => _GroupTimerScreenState();
}

class _GroupTimerScreenState extends State<GroupTimerScreen> {
  // 计时器状态
  TimerState _currentState = TimerState.setup;
  int _currentGroup = 1;
  int _totalGroups = 3; // 默认3组
  int _workDuration = 60; // 默认工作60秒
  int _restDuration = 30; // 默认休息30秒
  int _remainingTime = 0;
  bool _isRunning = false;
  Timer? _timer;
  
  // Constants for default values
  static const int defaultTotalGroups = 3;
  static const int defaultWorkDuration = 60; // 60 seconds
  static const int defaultRestDuration = 30; // 30 seconds


  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Check if we're in sequential training mode and auto-start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trainingModel = Provider.of<TrainingModel>(context, listen: false);
      // Auto-start if sequential mode is enabled
      if (trainingModel.isSequentialMode) {
        _startWorkout();
      }
    });
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
  
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _loadSettings() {
    try {
      final goalModel = Provider.of<GoalModel>(context, listen: false);
      final goal = goalModel.getGoal(widget.exerciseId);

      setState(() {
        if (goal != null) {
          _totalGroups = goal.sets > 0 ? goal.sets : defaultTotalGroups;
          _workDuration = goal.targetSeconds > 0 ? goal.targetSeconds : defaultWorkDuration;
          _restDuration = goal.restInterval >= 0 ? goal.restInterval : defaultRestDuration;
        } else {
          _totalGroups = defaultTotalGroups;
          _workDuration = defaultWorkDuration;
          _restDuration = defaultRestDuration;
        }
        _remainingTime = _workDuration;
      });
    } catch (e) {
      // Fallback to default values in case of any error
      setState(() {
        _totalGroups = defaultTotalGroups;
        _workDuration = defaultWorkDuration;
        _restDuration = defaultRestDuration;
        _remainingTime = _workDuration;
      });
      debugPrint('Error loading settings: $e');
    }
  }

  void _startTimer() {
    // Cancel any existing timer before starting a new one
    _cancelTimer();
    
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _cancelTimer();
        return;
      }
      
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _handleTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    
    setState(() {
      _isRunning = false;
    });
    _cancelTimer();
  }

  void _resetTimer() {
    _cancelTimer();
    
    setState(() {
      _isRunning = false;
      _currentState = TimerState.setup;
      _currentGroup = 1;
      _remainingTime = _workDuration;
    });
  }

  void _handleTimerComplete() {
    _cancelTimer();

    setState(() {
      if (_currentState == TimerState.work) {
        // 工作计时结束，进入休息
        if (_currentGroup < _totalGroups) {
          _currentState = TimerState.rest;
          _remainingTime = _restDuration;
          _isRunning = true; // 保持运行状态，自动开始休息计时
          _startTimer(); // 自动开始休息计时
        } else {
          // 所有组完成
          _currentState = TimerState.completed;
          _isRunning = false;
          _saveRecord();
        }
      } else if (_currentState == TimerState.rest) {
        // 休息结束，进入下一组工作
        _currentGroup++;
        _currentState = TimerState.work;
        _remainingTime = _workDuration;
        _isRunning = true; // 保持运行状态，自动开始下一组工作
        _startTimer(); // 自动开始下一组工作计时
      }
    });
  }

  void _startWorkout() {
    setState(() {
      _currentState = TimerState.work;
      _currentGroup = 1;
      _remainingTime = _workDuration;
    });
    _startTimer();
  }

  void _saveRecord() {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final totalDuration = _totalGroups * _workDuration;

    final record = TrainingRecord(
      exerciseId: widget.exerciseId,
      date: DateTime.now(),
      duration: totalDuration,
      count: _totalGroups,
    );
    trainingModel.addRecord(record);

    // Play cheer sound
    final soundService = SoundService();
    soundService.playCheerSound();

    // Check if we're in sequential training mode
    if (trainingModel.isSequentialTrainingActive) {
      final nextExerciseId = trainingModel.getNextSequentialExercise();

      if (nextExerciseId != null) {
        // Show completion screen with next training option
        _showCompletionScreen(nextExerciseId: nextExerciseId, totalDuration: totalDuration);
      } else {
        // End of sequence
        trainingModel.stopSequentialTraining();
        _showCompletionScreen(totalDuration: totalDuration);
      }
    } else {
      _showCompletionScreen(totalDuration: totalDuration);
    }
  }

  void _startNextTraining(String nextExerciseId, TrainingModel trainingModel) {
    if (!mounted) return;

    // Navigate to intro screen first for sequential training
    context.go('/exercise-intro/$nextExerciseId');
  }

  void _showCompletionScreen({String? nextExerciseId, required int totalDuration}) {
    if (!mounted) return;
    
    try {
      final trainingModel = Provider.of<TrainingModel>(context, listen: false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TrainingCompletionScreen(
          exerciseId: widget.exerciseId,
          count: _totalGroups,
          duration: totalDuration,
          sets: _totalGroups,
          repsPerSet: 1,
          onRestart: () {
            if (context.mounted) {
              Navigator.of(context).pop();
              _resetTimer();
              _startWorkout();
            }
          },
          onReturnHome: () {
            if (context.mounted) {
              Navigator.of(context).pop();
              // Clear sequential mode when returning to home
              trainingModel.clearSequentialMode();
              context.pop();
            }
          },
          onNextTraining: nextExerciseId != null ? () {
            if (context.mounted) {
              Navigator.of(context).pop();
              _startNextTraining(nextExerciseId, trainingModel);
              // 延迟移动到下一个练习，确保新页面能正确获取当前练习ID
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  trainingModel.moveToNextSequentialExercise();
                }
              });
            }
          } : null,
        ),
      );
    } catch (e) {
      debugPrint('Error showing completion screen: $e');
    }
  }



  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getStateText() {
    switch (_currentState) {
      case TimerState.setup:
        return '准备开始';
      case TimerState.work:
        return '第 $_currentGroup 组';
      case TimerState.rest:
        return '第 $_currentGroup 组休息';
      case TimerState.completed:
        return '训练完成';
    }
  }

  Color _getStateColor(TrainingExercise exercise) {
    switch (_currentState) {
      case TimerState.setup:
        return Colors.grey;
      case TimerState.work:
        return Colors.red;
      case TimerState.rest:
        return Colors.green;
      case TimerState.completed:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final baseExercise = trainingModel.getExerciseById(widget.exerciseId);

    if (baseExercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('错误'),
        ),
        body: const Center(
          child: Text('训练项目不存在'),
        ),
      );
    }

    // 创建带主题颜色的训练项目
    final exercise = TrainingExercise(
      id: baseExercise.id,
      name: baseExercise.name,
      description: baseExercise.description,
      type: baseExercise.type,
      icon: baseExercise.icon,
      color: themeModel.getExerciseColor(baseExercise.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        backgroundColor: exercise.color,
        foregroundColor: Colors.white,
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ..._buildTimerSection(exercise),
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
              children: _buildControlButtons(exercise),
            ),
          ),
        ],
      ),
    );
  }


  List<Widget> _buildTimerSection(TrainingExercise exercise) {
    final stateColor = _getStateColor(exercise);

    return [
      // 状态指示器
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: stateColor.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: stateColor, width: 2),
        ),
        child: Text(
          _getStateText(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: stateColor,
          ),
        ),
      ),
      const SizedBox(height: 20),

      // 进度指示器
      if (_currentState != TimerState.completed)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalGroups, (index) {
            final isCurrent = index + 1 == _currentGroup;
            final isCompleted = index + 1 < _currentGroup;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isCurrent
                        ? stateColor
                        : Colors.grey[300],
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      if (_currentState != TimerState.completed)
        const SizedBox(height: 20),

      // 主计时器
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: stateColor.withAlpha(25),
          shape: BoxShape.circle,
          border: Border.all(
            color: stateColor,
            width: 4,
          ),
        ),
        child: Center(
          child: Text(
            _formatTime(_remainingTime),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: stateColor,
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildControlButtons(TrainingExercise exercise) {
    final buttons = <Widget>[];

    if (_currentState == TimerState.setup) {
      buttons.add(
        IconButton(
          onPressed: _startWorkout,
          icon: const Icon(Icons.play_arrow),
          style: IconButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            iconSize: 32,
          ),
        ),
      );
    } else if (_currentState == TimerState.work || _currentState == TimerState.rest) {
      if (!_isRunning) {
        buttons.add(
          IconButton(
            onPressed: _startTimer,
            icon: const Icon(Icons.play_arrow),
            style: IconButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              iconSize: 32,
            ),
          ),
        );
      } else {
        buttons.add(
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
        );
      }
    }

    buttons.add(
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
    );

    return buttons;
  }

}

enum TimerState {
  setup,    // 设置状态
  work,     // 工作计时
  rest,     // 休息计时
  completed // 完成
}