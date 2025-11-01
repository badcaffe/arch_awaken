import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../services/sound_service.dart';
import 'training_completion_screen.dart';

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
  bool _isResting = false;
  int _countdownValue = 5;
  int _currentPhaseValue = 1;
  Timer? _countdownTimer;
  Timer? _autoCounterTimer;
  Timer? _trainingTimer;
  Timer? _restTimer;
  int _trainingDuration = 0;
  final SoundService _soundService = SoundService();

  // 可配置参数
  int _countInterval = 5; // 计数间隔（秒）
  int _prepareInterval = 1;  // 缓冲间隔（秒）

  // 分组训练参数
  int _currentSet = 1; // 当前组数
  int _totalSets = 3; // 总组数
  int _repsPerSet = 10; // 每组次数
  int _restBetweenSets = 30; // 组间休息时长（秒）
  int _currentRep = 0; // 当前组内计数

  // 训练模型引用
  late TrainingModel _trainingModel;

  @override
  void initState() {
    super.initState();
    _trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final goalModel = Provider.of<GoalModel>(context, listen: false);
    final goal = goalModel.getGoal(widget.exerciseId);
    _repsPerSet = goal?.repsPerSet ?? 10;
    _totalSets = goal?.sets ?? 3;
    _countInterval = goal?.countInterval ?? 5;
    _prepareInterval = goal?.prepareInterval ?? 1;
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
    final target = goal?.repsPerSet ?? 10;
    final sets = goal?.sets ?? 3;
    final countInterval = goal?.countInterval ?? 5;
    final prepareInterval = goal?.prepareInterval ?? 1;

    print('🚀 开始训练: ${widget.exerciseId}, 每组次数: $target, 总组数: $sets, 计数中: ${countInterval}秒, 缓冲中: ${prepareInterval}秒');

    setState(() {
      _isRunning = true;
      _isCountingDown = true;
      _countdownValue = 5;
      _currentSet = 1;
      _currentRep = 0;
      _count = 0;
      _repsPerSet = target;
      _totalSets = sets;
      _countInterval = countInterval;
      _prepareInterval = prepareInterval;
    });

    _startCountdown();
  }

  void _startCountdown() {
    // 播放倒计时开始的声音
    _soundService.playCountdownSound();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdownValue > 1) {
          _countdownValue--;
          _soundService.playCountdownSound();
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
    _isResting = false;

    // 立即播放第一个数字1
    _soundService.playNumberSound(_currentPhaseValue);

    _autoCounterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_isResting) {
          // 准备休息阶段
          if (_countdownValue > 1) {
            _countdownValue--;
          } else {
            // 休息结束，开始下一组
            _isResting = false;
            _isCountingDown = true;
            _countdownValue = 5;
            _soundService.playRestEndSound(); // 播放休息结束声音
            _startCountdown();
            timer.cancel();
          }
        } else if (!_isPreparing) {
          // 计数阶段
          if (_currentPhaseValue < _countInterval) {
            _currentPhaseValue++;
            // 播放数字声音 (1-2-3-4-5)
            _soundService.playNumberSound(_currentPhaseValue);
          } else {
            // 计数阶段结束，进入缓冲阶段
            _currentPhaseValue = 1;
            _isPreparing = true;
            // 进入缓冲阶段时立即播放gudu声音
            _soundService.playGuduSound();
          }
        } else {
          // 缓冲阶段
          if (_currentPhaseValue < _prepareInterval) {
            _currentPhaseValue++;
            // 播放咕嘟声音（缓冲中每秒计时）
            _soundService.playGuduSound();
          } else {
            // 缓冲结束，完成一次训练
            _count++;
            _currentRep++;
            _currentPhaseValue = 1;
            _isPreparing = false;
            // 开始新一轮计数时立即播放数字1
            _soundService.playNumberSound(_currentPhaseValue);

            // 检查是否完成当前组
            if (_currentRep >= _repsPerSet) {
              // 完成当前组
              _currentRep = 0;

              // 检查是否完成所有组
              if (_currentSet >= _totalSets) {
                // 完成所有训练
                print('🎯 完成所有训练: $_totalSets 组, 每组 $_repsPerSet 次');
                _pauseTraining();
                _completeTraining();
              } else {
                // 进入组间休息
                _currentSet++;
                _isResting = true;
                _countdownValue = _restBetweenSets;
                _soundService.playRestStartSound(); // 播放休息开始声音
              }
            }
          }
        }
      });
    });
  }

  void _startTrainingTimer() {
    _trainingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
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
    _restTimer?.cancel();
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
      _isResting = false;
      _countdownValue = 5;
      _currentPhaseValue = 1;
      _trainingDuration = 0;
      _currentSet = 1;
      _currentRep = 0;
    });
    _countdownTimer?.cancel();
    _autoCounterTimer?.cancel();
    _trainingTimer?.cancel();
    _restTimer?.cancel();
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

    // Show beautiful completion screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TrainingCompletionScreen(
        exerciseId: widget.exerciseId,
        count: _count,
        duration: _trainingDuration,
        sets: _totalSets,
        repsPerSet: _repsPerSet,
        onRestart: () {
          Navigator.of(context).pop();
          _resetTraining();
        },
        onReturnHome: () {
          Navigator.of(context).pop();
          context.pop();
        },
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
                      value: Provider.of<GoalModel>(context, listen: false).getGoal(widget.exerciseId)?.countInterval ?? 5,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          Provider.of<GoalModel>(context, listen: false).setCountInterval(widget.exerciseId, value!);
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
                    const Text('缓冲间隔:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: Provider.of<GoalModel>(context, listen: false).getGoal(widget.exerciseId)?.prepareInterval ?? 1,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          Provider.of<GoalModel>(context, listen: false).setPrepareInterval(widget.exerciseId, value!);
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
                    const Text('每组次数:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: Provider.of<GoalModel>(context, listen: false).getGoal(widget.exerciseId)?.repsPerSet ?? 10,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          Provider.of<GoalModel>(context, listen: false).setRepsPerSet(widget.exerciseId, value!);
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('训练组数:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: Provider.of<GoalModel>(context, listen: false).getGoal(widget.exerciseId)?.sets ?? 3,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          Provider.of<GoalModel>(context, listen: false).setSets(widget.exerciseId, value!);
                        });
                      },
                      items: [1, 2, 3, 4, 5, 6, 8, 10].map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 组'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('组间休息:'),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _restBetweenSets,
                      onChanged: _isRunning ? null : (value) {
                        setDialogState(() {
                          _restBetweenSets = value!;
                        });
                      },
                      items: [10, 15, 20, 30, 45, 60, 90, 120].map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 秒'),
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
    if (_isResting) {
      return '组间休息';
    } else if (_isCountingDown) {
      return '准备开始';
    } else if (_isPreparing) {
      return '缓冲中';
    } else {
      return '计数中';
    }
  }

  String _getPhaseDescription() {
    if (_isResting) {
      return '第 $_currentSet 组休息 $_countdownValue 秒';
    } else if (_isCountingDown) {
      return '$_countdownValue 秒后开始自动计数';
    } else if (_isPreparing) {
      return '缓冲 $_currentPhaseValue/$_prepareInterval 秒';
    } else {
      return '计数 $_currentPhaseValue/$_countInterval 秒';
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
    if (_isResting) {
      displayColor = Colors.blue;
    } else if (_isCountingDown) {
      displayColor = const Color(0xFF00695C);
    } else if (_isPreparing) {
      displayColor = const Color(0xFFEBA236);
    } else {
      displayColor = exercise.color;
    }

    int displayValue;
    if (_isResting) {
      displayValue = _countdownValue;
    } else if (_isCountingDown) {
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              // 状态指示器 - 显示当前组数
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: displayColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: displayColor, width: 2),
                ),
                child: Text(
                  _getCounterStateText(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 进度指示器 - 显示组数进度
              if (_currentSet > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalSets, (index) {
                    final isCurrent = index + 1 == _currentSet;
                    final isCompleted = index + 1 < _currentSet;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                                ? displayColor
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              if (_currentSet > 0)
                const SizedBox(height: 20),

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
              // 训练信息 - 显示当前次数和总完成次数
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '第$_currentRep/$_repsPerSet次',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: displayColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '总完成: $_count 次',
                    style: TextStyle(
                      fontSize: 16,
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
                    IconButton(
                      onPressed: _startTraining,
                      icon: const Icon(Icons.play_arrow),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        iconSize: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: _resetTraining,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        iconSize: 32,
                      ),
                    ),
                  ],
                )
              else if (_isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _pauseTraining,
                      icon: const Icon(Icons.pause),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        iconSize: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: _resetTraining,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        iconSize: 32,
                      ),
                    ),
                  ],
                )
              else if (!_isRunning && _count > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _resumeTraining,
                      icon: const Icon(Icons.play_arrow),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        iconSize: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: _completeTraining,
                      icon: const Icon(Icons.check),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        iconSize: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: _resetTraining,
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
            ],
          ),
          ),
        ),
      ),
    );
  }

  String _getCounterStateText() {
    if (_isResting) {
      return '第$_currentSet组休息';
    } else if (_currentSet > 0) {
      return '第$_currentSet组';
    } else {
      return '准备开始';
    }
  }
}