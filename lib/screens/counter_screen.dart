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

  // 长按计次相关（用于瑜伽砖捡球）
  bool _isLongPressing = false;
  Timer? _longPressTimer;
  int _longPressProgress = 0;
  String _countMode = 'longPress'; // 计次模式: 'tap' 或 'longPress'
  int _longPressDuration = 3; // 长按时长（秒），从设置中读取
  bool _isLeftFoot = true; // 当前是否为左脚（用于瑜伽砖捡球）

  // 点击动画相关
  double _circleScale = 1.0;

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
    _countMode = goal?.countMode ?? 'longPress';
    _longPressDuration = goal?.longPressDuration ?? 3;

    // Check if we're in sequential training mode and auto-start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-start if sequential mode is enabled
      if (_trainingModel.isSequentialMode) {
        _startTraining();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoCounterTimer?.cancel();
    _trainingTimer?.cancel();
    _longPressTimer?.cancel();
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

    print('🚀 开始训练: ${widget.exerciseId}, 每组次数: $target, 总组数: $sets, 计数中: $countInterval秒, 缓冲中: $prepareInterval秒');

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
      _isLeftFoot = true; // 开始时重置为左脚
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
    // 瑜伽砖捡球使用长按计次，不使用自动计数
    if (widget.exerciseId == 'yoga_brick_ball_pickup') {
      return;
    }

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
      _isLongPressing = false;
      _longPressProgress = 0;
      _isLeftFoot = true; // 重置为左脚
    });
    _countdownTimer?.cancel();
    _autoCounterTimer?.cancel();
    _trainingTimer?.cancel();
    _restTimer?.cancel();
    _longPressTimer?.cancel();
    _soundService.stopAllSounds();
  }

  // 长按开始（仅长按模式）
  void _onLongPressStart() {
    if (!_isRunning || widget.exerciseId != 'yoga_brick_ball_pickup' || _countMode != 'longPress' || _isResting || _isCountingDown) {
      return;
    }

    setState(() {
      _isLongPressing = true;
      _longPressProgress = 0;
    });

    _longPressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _longPressProgress += 100;

        // 每秒播放一次声音反馈
        if (_longPressProgress % 1000 == 0) {
          _soundService.playNumberSound(_longPressProgress ~/ 1000);
        }

        // 长按超过设定时长，计次加一
        if (_longPressProgress >= _longPressDuration * 1000) {
          _onLongPressComplete();
          timer.cancel();
        }
      });
    });
  }

  // 短按计次（仅短按模式）
  void _onTap() {
    if (!_isRunning || widget.exerciseId != 'yoga_brick_ball_pickup' || _countMode != 'tap' || _isResting || _isCountingDown) {
      return;
    }

    // 触发点击动画
    _animateCircleTap();

    setState(() {
      _count++;
      _currentRep++;
    });

    // 播放成功声音
    _soundService.playGuduSound();

    // 检查是否完成当前脚的训练
    if (_currentRep >= _repsPerSet) {
      // 切换到另一只脚
      if (_isLeftFoot) {
        setState(() {
          _isLeftFoot = false;
          _currentRep = 0;
        });
        // 切换脚时不播放声音
      } else {
        // 两只脚都完成，重置到左脚并进入组间休息
        setState(() {
          _isLeftFoot = true;
          _currentRep = 0;
        });

        // 检查是否完成所有组
        if (_currentSet >= _totalSets) {
          // 完成所有训练
          print('🎯 完成所有训练: $_totalSets 组, 每组 $_repsPerSet 次');
          _pauseTraining();
          _completeTraining();
        } else {
          // 进入组间休息
          setState(() {
            _currentSet++;
            _isResting = true;
            _countdownValue = _restBetweenSets;
          });
          _soundService.playRestStartSound();
          _startRestTimer();
        }
      }
    }
  }

  // 长按结束（未达到3秒）
  void _onLongPressEnd() {
    _longPressTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _isLongPressing = false;
      _longPressProgress = 0;
    });
  }

  // 长按完成（达到设定时长）
  void _onLongPressComplete() {
    _longPressTimer?.cancel();

    if (!mounted) return;

    // 触发完成动画
    _animateCircleTap();

    setState(() {
      _isLongPressing = false;
      _longPressProgress = 0;
      _count++;
      _currentRep++;
    });

    // 播放成功声音
    _soundService.playGuduSound();

    // 检查是否完成当前脚的训练
    if (_currentRep >= _repsPerSet) {
      // 切换到另一只脚
      if (_isLeftFoot) {
        setState(() {
          _isLeftFoot = false;
          _currentRep = 0;
        });
        // 切换脚时不播放声音
      } else {
        // 两只脚都完成，重置到左脚并进入组间休息
        setState(() {
          _isLeftFoot = true;
          _currentRep = 0;
        });

        // 检查是否完成所有组
        if (_currentSet >= _totalSets) {
          // 完成所有训练
          print('🎯 完成所有训练: $_totalSets 组, 每组 $_repsPerSet 次');
          _pauseTraining();
          _completeTraining();
        } else {
          // 进入组间休息
          setState(() {
            _currentSet++;
            _isResting = true;
            _countdownValue = _restBetweenSets;
          });
          _soundService.playRestStartSound();
          _startRestTimer();
        }
      }
    }
  }

  // 组间休息计时器
  void _startRestTimer() {
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_countdownValue > 1) {
          _countdownValue--;
        } else {
          // 休息结束
          _isResting = false;
          _countdownValue = 5;
          _soundService.playRestEndSound();
          timer.cancel();
        }
      });
    });
  }

  // 点击动画效果
  void _animateCircleTap() {
    if (!mounted) return;

    setState(() {
      _circleScale = 0.9; // 缩小到90%
    });

    // 200ms后恢复原大小
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _circleScale = 1.0;
        });
      }
    });
  }

  void _completeTraining() {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);
    final goalModel = Provider.of<GoalModel>(context, listen: false);

    final record = TrainingRecord(
      exerciseId: widget.exerciseId,
      date: DateTime.now(),
      duration: _trainingDuration,
      count: _count,
    );
    trainingModel.addRecord(record);

    // 播放完成声音
    _soundService.playCheerSound();

    // Check if we're in sequential training mode
    if (trainingModel.isSequentialTrainingActive) {
      final nextExerciseId = trainingModel.getNextSequentialExercise();

      if (nextExerciseId != null) {
        // Show completion screen with next training option
        _showRegularCompletionScreen(nextExerciseId: nextExerciseId);
      } else {
        // End of sequence
        trainingModel.stopSequentialTraining();
        _showRegularCompletionScreen();
      }
    } else {
      _showRegularCompletionScreen();
    }
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

  void _showRegularCompletionScreen({String? nextExerciseId}) {
    final trainingModel = Provider.of<TrainingModel>(context, listen: false);

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
        onNextTraining: nextExerciseId != null ? () {
          Navigator.of(context).pop();
          _startNextTraining(nextExerciseId, trainingModel);
          // 延迟移动到下一个练习，确保新页面能正确获取当前练习ID
          WidgetsBinding.instance.addPostFrameCallback((_) {
            trainingModel.moveToNextSequentialExercise();
              // Auto-start if sequential mode is enabled
              if (trainingModel.isSequentialMode) {
                _startTraining();
              }
          });
        } : null,
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
    if (widget.exerciseId == 'yoga_brick_ball_pickup') {
      if (_isResting) {
        return '组间休息';
      } else if (_isCountingDown) {
        return '准备开始';
      } else if (_isLongPressing) {
        return '长按中';
      } else {
        if (_countMode == 'tap') {
          return '点击计次';
        } else {
          return '等待长按';
        }
      }
    }

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
    if (widget.exerciseId == 'yoga_brick_ball_pickup') {
      if (_isResting) {
        return '第 $_currentSet 组休息 $_countdownValue 秒';
      } else if (_isCountingDown) {
        return '$_countdownValue 秒后开始训练';
      } else if (_isLongPressing) {
        final progress = (_longPressProgress / 1000).toStringAsFixed(1);
        return '已长按 $progress/$_longPressDuration 秒';
      } else {
        if (_countMode == 'tap') {
          return '点击大圆计次';
        } else {
          return '长按大圆 $_longPressDuration 秒计次';
        }
      }
    }

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
    } else if (widget.exerciseId == 'yoga_brick_ball_pickup' && _isLongPressing) {
      displayColor = const Color(0xFFFF6B35); // 长按时显示橙红色
    } else if (_isPreparing) {
      displayColor = const Color(0xFFEBA236);
    } else {
      displayColor = exercise.color;
    }

    int displayValue;
    if (widget.exerciseId == 'yoga_brick_ball_pickup') {
      // 瑜伽砖捡球显示当前次数或倒计时
      if (_isResting) {
        displayValue = _countdownValue;
      } else if (_isCountingDown) {
        displayValue = _countdownValue;
      } else if (_isLongPressing) {
        displayValue = (_longPressProgress / 1000).ceil();
      } else {
        // 训练中显示当前次数
        displayValue = _currentRep;
      }
    } else {
      // 其他项目显示自动计数
      if (_isResting) {
        displayValue = _countdownValue;
      } else if (_isCountingDown) {
        displayValue = _countdownValue;
      } else {
        displayValue = _currentPhaseValue;
      }
    }

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
        actions: [
          if (!_isRunning)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // 可滚动的内容区域
          Expanded(
            child: SingleChildScrollView(
              // 瑜伽砖捡球禁止滚动，避免长按时误触滚动
              physics: widget.exerciseId == 'yoga_brick_ball_pickup'
                  ? const NeverScrollableScrollPhysics()
                  : null,
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
                          GestureDetector(
                            // 短按模式使用onTap
                            onTap: widget.exerciseId == 'yoga_brick_ball_pickup' && _countMode == 'tap'
                                ? _onTap
                                : null,
                            // 长按模式使用onLongPress
                            onLongPressStart: widget.exerciseId == 'yoga_brick_ball_pickup' && _countMode == 'longPress'
                                ? (_) => _onLongPressStart()
                                : null,
                            onLongPressEnd: widget.exerciseId == 'yoga_brick_ball_pickup' && _countMode == 'longPress'
                                ? (_) => _onLongPressEnd()
                                : null,
                            child: AnimatedScale(
                              scale: _circleScale,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 背景圆圈
                                  Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: displayColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: displayColor,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  // 长按进度指示器（仅瑜伽砖捡球显示）
                                  if (widget.exerciseId == 'yoga_brick_ball_pickup' && _isLongPressing)
                                    SizedBox(
                                      width: 250,
                                      height: 250,
                                      child: CircularProgressIndicator(
                                        value: _longPressProgress / (_longPressDuration * 1000),
                                        strokeWidth: 8,
                                        backgroundColor: Colors.transparent,
                                        valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                                      ),
                                    ),
                                  // 显示数字
                                  Text(
                                    displayValue.toString(),
                                    style: TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: displayColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 状态文字（瑜伽砖捡球不显示）
                          if (widget.exerciseId != 'yoga_brick_ball_pickup')
                            Text(
                              _getPhaseText(),
                              style: TextStyle(
                                fontSize: 24,
                                color: displayColor,
                              ),
                            ),
                          if (widget.exerciseId != 'yoga_brick_ball_pickup')
                            const SizedBox(height: 10),
                          if (widget.exerciseId != 'yoga_brick_ball_pickup')
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
                      // 训练信息 - 显示当前次数和总完成次数（瑜伽砖捡球不显示）
                      if (widget.exerciseId != 'yoga_brick_ball_pickup')
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
                      if (widget.exerciseId != 'yoga_brick_ball_pickup')
                        const SizedBox(height: 20),

                      // 左右脚图形示意（仅瑜伽砖捡球显示）
                      if (widget.exerciseId == 'yoga_brick_ball_pickup')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 左脚
                            Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: _isLeftFoot
                                        ? displayColor.withAlpha(25)
                                        : Colors.grey.withAlpha(25),
                                    border: Border.all(
                                      color: _isLeftFoot ? displayColor : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/footprint_l.png',
                                      width: 40,
                                      height: 60,
                                      color: _isLeftFoot ? displayColor : Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '左脚',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _isLeftFoot ? displayColor : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 80),
                            // 右脚
                            Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: !_isLeftFoot
                                        ? displayColor.withAlpha(25)
                                        : Colors.grey.withAlpha(25),
                                    border: Border.all(
                                      color: !_isLeftFoot ? displayColor : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/footprint_r.png',
                                      width: 40,
                                      height: 60,
                                      color: !_isLeftFoot ? displayColor : Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '右脚',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: !_isLeftFoot ? displayColor : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (widget.exerciseId == 'yoga_brick_ball_pickup')
                        const SizedBox(height: 20),

                      // 总完成次数（仅瑜伽砖捡球显示）
                      if (widget.exerciseId == 'yoga_brick_ball_pickup')
                        Text(
                          '总完成: $_count 次',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: displayColor,
                          ),
                        ),
                      if (widget.exerciseId == 'yoga_brick_ball_pickup')
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
                    ],
                  ),
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
            child: _buildControlButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    if (!_isRunning && _count == 0) {
      return Row(
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
      );
    } else if (_isRunning) {
      return Row(
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
      );
    } else if (!_isRunning && _count > 0) {
      return Row(
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
      );
    }
    return const SizedBox.shrink();
  }

  String _getCounterStateText() {
    if (widget.exerciseId == 'yoga_brick_ball_pickup') {
      if (_isResting) {
        return '第$_currentSet组休息';
      } else if (_currentSet > 0) {
        final footText = _isLeftFoot ? '左脚' : '右脚';
        return '第$_currentSet组 - $footText';
      } else {
        return '准备开始';
      }
    }

    if (_isResting) {
      return '第$_currentSet组休息';
    } else if (_currentSet > 0) {
      return '第$_currentSet组';
    } else {
      return '准备开始';
    }
  }
}