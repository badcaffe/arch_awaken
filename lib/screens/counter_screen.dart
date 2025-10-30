import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../services/sound_service.dart';

class CounterScreen extends StatefulWidget {
  final String exerciseId;

  const CounterScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  bool _isRunning = false;
  bool _isCountingDown = false;
  bool _isPreparing = false;
  int _countdownValue = 5;
  int _currentPhaseValue = 1;
  Timer? _countdownTimer;
  Timer? _autoCounterTimer;
  Timer? _trainingTimer;
  int _trainingDuration = 0;
  final SoundService _soundService = SoundService();

  // 可配置参数
  int _countInterval = 5; // 计数间隔（秒）
  int _prepareInterval = 1;  // 准备间隔（秒）
  int _currentTargetCount = 10; // 当前训练的目标次数

  // 训练模型引用
  late TrainingModel _trainingModel;

  @override
  void initState() {
    super.initState();
    _trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final goalModel = Provider.of<GoalModel>(context, listen: false);
    final goal = goalModel.getGoal(widget.exerciseId);
    _currentTargetCount = goal?.targetCount ?? 10;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoCounterTimer?.cancel();
    _trainingTimer?.cancel();
    _soundService.dispose();
    super.dispose();
  }

  void _startTraining() {
    final goalModel = Provider.of<GoalModel>(context, listen: false);
    final goal = goalModel.getGoal(widget.exerciseId);
    final target = goal?.targetCount ?? 10;

    print('🚀 开始训练: ${widget.exerciseId}, 目标次数: $target');

    setState(() {
      _isRunning = true;
      _isCountingDown = true;
      _countdownValue = 5;
      _currentTargetCount = target;
    });

    _startCountdown();
  }

  void _startCountdown() {
    // 播放倒计时开始的声音
    _soundService.playCountdownSound();
    // 立即播放第一个倒计时数字（5）
    _soundService.playNumberSound(_countdownValue);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownValue > 1) {
          _countdownValue--;
          // 播放倒计时的数字声音
          _soundService.playNumberSound(_countdownValue);
        } else {
          _isCountingDown = false;
          _countdownValue = 5;
          timer.cancel();
          _startAutoCounter();
          _startTrainingTimer();
        }
      });
    });
  }

  void _startAutoCounter() {
    _currentPhaseValue = 1;
    _isPreparing = false;

    // 立即播放第一个数字1
    _soundService.playNumberSound(_currentPhaseValue);

    _autoCounterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (!_isPreparing) {
          // 计数阶段
          if (_currentPhaseValue < _countInterval) {
            _currentPhaseValue++;
            // 播放数字声音 (1-2-3-4-5)
            _soundService.playNumberSound(_currentPhaseValue);
          } else {
            // 完成一次计数，进入准备阶段
            _count++;
            _currentPhaseValue = 1;
            _isPreparing = true;

            // 检查是否达到目标计次
            final goalModel = Provider.of<GoalModel>(context, listen: false);
            final goal = goalModel.getGoal(widget.exerciseId);
            final currentTarget = goal?.targetCount ?? 10;
            if (_count >= currentTarget) {
              print('🎯 达到目标: $_count >= $currentTarget, 自动结束训练');
              _pauseTraining();
              _completeTraining();
            }
          }
        } else {
          // 准备阶段
          if (_currentPhaseValue < _prepareInterval) {
            _currentPhaseValue++;
          } else {
            // 准备结束，开始新一轮计数
            _currentPhaseValue = 1;
            _isPreparing = false;
            // 开始新一轮计数时立即播放数字1
            _soundService.playNumberSound(_currentPhaseValue);
          }
        }
      });
    });
  }

  void _startTrainingTimer() {
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _trainingDuration++;
      });
    });
  }

  void _pauseTraining() {
    setState(() {
      _isRunning = false;
    });
    _countdownTimer?.cancel();
    _autoCounterTimer?.cancel();
    _trainingTimer?.cancel();
    _soundService.stopAllSounds();
  }

  void _resumeTraining() {
    setState(() {
      _isRunning = true;
    });
    _startAutoCounter();
    _startTrainingTimer();
  }

  void _resetTraining() {
    setState(() {
      _count = 0;
      _isRunning = false;
      _isCountingDown = false;
      _isPreparing = false;
      _countdownValue = 5;
      _currentPhaseValue = 1;
      _trainingDuration = 0;
    });
    _countdownTimer?.cancel();
    _autoCounterTimer?.cancel();
    _trainingTimer?.cancel();
    _soundService.stopAllSounds();
  }

  void _completeTraining() {
    final record = TrainingRecord(
      exerciseId: widget.exerciseId,
      date: DateTime.now(),
      duration: _trainingDuration,
      count: _count,
    );
    _trainingModel.addRecord(record);

    // 播放完成声音
    _soundService.playCheerSound();

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('训练完成'),
        content: Text('完成 $_count 次训练，用时 $_trainingDuration 秒'),
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('训练设置'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('计数间隔:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _countInterval,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          _countInterval = value!;
                        });
                      },
                      items: [3, 4, 5, 6, 7, 8, 9, 10].map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 秒'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('准备间隔:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _prepareInterval,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          _prepareInterval = value!;
                        });
                      },
                      items: [1, 2, 3, 4, 5].map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 秒'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('目标计次:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: Provider.of<GoalModel>(context, listen: false).getGoal(widget.exerciseId)?.targetCount ?? 10,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          Provider.of<GoalModel>(context, listen: false).setTargetCount(widget.exerciseId, value!);
                        });
                      },
                      items: [5, 10, 15, 20, 25, 30, 40, 50].map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 次'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getPhaseText() {
    if (_isCountingDown) {
      return '准备开始';
    } else if (_isPreparing) {
      return '准备中';
    } else {
      return '计数中';
    }
  }

  String _getPhaseDescription() {
    if (_isCountingDown) {
      return '$_countdownValue 秒后开始自动计数';
    } else if (_isPreparing) {
      return '准备 $_currentPhaseValue/$_prepareInterval 秒';
    } else {
      return '计数 $_currentPhaseValue/$_countInterval 秒';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final goalModel = Provider.of<GoalModel>(context);
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

    // Create exercise with theme color
    final exercise = TrainingExercise(
      id: baseExercise.id,
      name: baseExercise.name,
      description: baseExercise.description,
      type: baseExercise.type,
      icon: baseExercise.icon,
      color: themeModel.getExerciseColor(baseExercise.id),
    );

    Color displayColor;
    if (_isCountingDown) {
      displayColor = const Color(0xFF00695C);
    } else if (_isPreparing) {
      displayColor = Colors.orange;
    } else {
      displayColor = exercise.color;
    }

    int displayValue;
    if (_isCountingDown) {
      displayValue = _countdownValue;
    } else {
      displayValue = _currentPhaseValue;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        backgroundColor: exercise.color,
        foregroundColor: Colors.white,
        actions: [
          if (!_isRunning)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main display
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: displayColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: displayColor,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        displayValue.toString(),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: displayColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _getPhaseText(),
                    style: TextStyle(
                      fontSize: 24,
                      color: displayColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getPhaseDescription(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Training info
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '已完成: $_count/$_currentTargetCount 次',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                exercise.description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Control buttons
              if (!_isRunning && _count == 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _startTraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(64, 64),
                      ),
                      child: const Icon(Icons.play_arrow),
                    ),
                    ElevatedButton(
                      onPressed: _resetTraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(64, 64),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                )
              else if (_isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pauseTraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(64, 64),
                      ),
                      child: const Icon(Icons.pause),
                    ),
                    ElevatedButton(
                      onPressed: _resetTraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(64, 64),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                )
              else if (!_isRunning && _count > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _resumeTraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(64, 64),
                      ),
                      child: const Icon(Icons.play_arrow),
                    ),
                    ElevatedButton(
                      onPressed: _completeTraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(64, 64),
                      ),
                      child: const Icon(Icons.check),
                    ),
                    ElevatedButton(
                      onPressed: _resetTraining,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(64, 64),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}