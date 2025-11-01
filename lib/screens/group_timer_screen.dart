import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';

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

  // 设置状态
  bool _isEditingSettings = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadSettings() {
    // 这里可以加载用户保存的设置
    // 暂时使用默认值
    setState(() {
      _remainingTime = _workDuration;
    });
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _currentState = TimerState.setup;
      _currentGroup = 1;
      _remainingTime = _workDuration;
    });
    _timer?.cancel();
  }

  void _handleTimerComplete() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;

      if (_currentState == TimerState.work) {
        // 工作计时结束，进入休息
        if (_currentGroup < _totalGroups) {
          _currentState = TimerState.rest;
          _remainingTime = _restDuration;
        } else {
          // 所有组完成
          _currentState = TimerState.completed;
          _saveRecord();
        }
      } else if (_currentState == TimerState.rest) {
        // 休息结束，进入下一组工作
        _currentGroup++;
        _currentState = TimerState.work;
        _remainingTime = _workDuration;
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

    // 显示完成对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('训练完成'),
        content: Text('已完成 $_totalGroups 组训练！\n总时长: ${totalDuration ~/ 60}分${totalDuration % 60}秒'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _toggleSettings() {
    setState(() {
      _isEditingSettings = !_isEditingSettings;
    });
  }

  void _updateWorkDuration(int duration) {
    setState(() {
      _workDuration = duration;
      if (_currentState == TimerState.setup) {
        _remainingTime = duration;
      }
    });
  }

  void _updateRestDuration(int duration) {
    setState(() {
      _restDuration = duration;
    });
  }

  void _updateTotalGroups(int groups) {
    setState(() {
      _totalGroups = groups;
    });
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
        actions: [
          IconButton(
            icon: Icon(_isEditingSettings ? Icons.check : Icons.settings),
            onPressed: _toggleSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            if (_isEditingSettings) ..._buildSettingsSection(exercise),
            if (!_isEditingSettings) ..._buildTimerSection(exercise),
          ],
        ),
        ),
      ),
    );
  }

  List<Widget> _buildSettingsSection(TrainingExercise exercise) {
    return [
      Text(
        '训练设置',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: exercise.color,
        ),
      ),
      const SizedBox(height: 20),
      _buildSettingItem(
        '每组时长 (秒)',
        _workDuration,
        _updateWorkDuration,
        [30, 45, 60, 90, 120],
      ),
      const SizedBox(height: 16),
      _buildSettingItem(
        '休息时长 (秒)',
        _restDuration,
        _updateRestDuration,
        [15, 30, 45, 60],
      ),
      const SizedBox(height: 16),
      _buildSettingItem(
        '组数',
        _totalGroups,
        _updateTotalGroups,
        [1, 2, 3, 4, 5],
      ),
      const SizedBox(height: 40),
      ElevatedButton.icon(
        onPressed: () {
          _toggleSettings();
          _resetTimer();
        },
        icon: const Icon(Icons.check),
        label: const Text('确认设置'),
        style: ElevatedButton.styleFrom(
          backgroundColor: exercise.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    ];
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
      if (_currentState != TimerState.setup && _currentState != TimerState.completed)
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
      if (_currentState != TimerState.setup && _currentState != TimerState.completed)
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

      // 控制按钮
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildControlButtons(exercise),
      ),
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

  Widget _buildSettingItem(
    String title,
    int currentValue,
    Function(int) onUpdate,
    List<int> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((value) {
            final isSelected = currentValue == value;
            return ChoiceChip(
              label: Text('$value'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onUpdate(value);
                }
              },
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

enum TimerState {
  setup,    // 设置状态
  work,     // 工作计时
  rest,     // 休息计时
  completed // 完成
}