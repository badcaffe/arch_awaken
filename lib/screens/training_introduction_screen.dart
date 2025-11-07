import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/training_model.dart';
import '../models/theme_model.dart';

class TrainingIntroductionScreen extends StatelessWidget {
  final String exerciseId;

  const TrainingIntroductionScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final exercise = trainingModel.getExerciseById(exerciseId);

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('训练介绍'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const Center(
          child: Text('训练项目未找到'),
        ),
      );
    }

    final themedExercise = TrainingExercise(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      type: exercise.type,
      icon: exercise.icon,
      color: themeModel.getExerciseColor(exercise.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练介绍'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header with icon and name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themedExercise.color.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        themedExercise.icon,
                        size: 36,
                        color: themedExercise.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            themedExercise.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: themedExercise.type == ExerciseType.timer
                                  ? Colors.blue.withAlpha(25)
                                  : Colors.green.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              themedExercise.type == ExerciseType.timer
                                  ? '计时训练'
                                  : '计次训练',
                              style: TextStyle(
                                fontSize: 12,
                                color: themedExercise.type == ExerciseType.timer
                                    ? Colors.blue
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Training introduction text
            const Text(
              '训练介绍',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _getTrainingIntroduction(themedExercise.id),
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sample video section
            const Text(
              '示范视频',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${themedExercise.name} 示范视频',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '视频内容待添加',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Start training button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (themedExercise.id == 'foot_ball_rolling') {
                    context.go('/foot-ball-rolling/${themedExercise.id}');
                  } else if (themedExercise.type == ExerciseType.timer) {
                    // 所有计时训练都使用组计时器
                    context.go('/group-timer/${themedExercise.id}');
                  } else {
                    context.go('/counter/${themedExercise.id}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themedExercise.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '开始训练',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTrainingIntroduction(String exerciseId) {
    switch (exerciseId) {
      case 'ball_tiptoe':
        return '夹球踮脚训练主要锻炼脚踝稳定性和小腿肌肉力量。通过夹住瑜伽球进行踮脚动作，可以有效提升平衡能力和脚部肌肉耐力。建议每组10-15次，每天进行3-4组训练。';
      case 'yoga_brick_tiptoe':
        return '瑜伽砖踮脚训练专注于提升脚踝稳定性和小腿肌肉力量。使用瑜伽砖作为支撑进行踮脚动作，能够有效增强平衡能力和脚部肌肉耐力。建议每组10-15次，每天进行3-4组训练。';
      case 'yoga_brick_ball_pickup':
        return '瑜伽砖捡球训练结合了平衡和协调能力的锻炼。通过使用瑜伽砖捡起球体的动作，能够有效提升脚踝稳定性和身体协调性。建议每组8-12次，每天进行3-4组训练。';
      case 'frog_pose':
        return '青蛙趴训练主要针对髋关节灵活性和大腿内侧肌肉的拉伸。这个姿势能够有效缓解久坐带来的髋部紧张，改善身体柔韧性。建议每次保持30-60秒，每天进行3-5次训练。';
      case 'glute_bridge':
        return '臀桥训练专注于臀部肌肉的激活和强化。这个动作能够有效提升臀大肌力量，改善骨盆稳定性，缓解腰部压力。建议每组12-15次，每天进行3-4组训练。';
      case 'stretching':
        return '拉伸训练旨在提升身体柔韧性和关节活动范围。通过系统的拉伸动作，能够有效缓解肌肉紧张，改善身体姿态，预防运动损伤。建议每次保持15-30秒，每天进行全身各部位的拉伸。';
      case 'foot_ball_rolling':
        return '脚底滚球训练是一种有效的足底按摩和足弓训练方法。通过使用小球在脚底进行滚动，能够有效放松足底筋膜，增强足弓力量，改善扁平足问题。训练分为左右滚动、前后滚动和脚后跟滚动三个部分，每部分持续1分钟，左右脚各训练一轮。建议每天进行1-2次完整的训练。';
      default:
        return '这是一个有效的训练项目，能够帮助您提升身体素质和健康水平。请按照正确的姿势和节奏进行训练，确保训练效果和安全性。';
    }
  }
}