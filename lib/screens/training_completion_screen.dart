import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/training_model.dart';
import '../models/theme_model.dart';

class TrainingCompletionScreen extends StatefulWidget {
  final String exerciseId;
  final int count;
  final int duration;
  final int sets;
  final int repsPerSet;
  final VoidCallback onRestart;
  final VoidCallback onReturnHome;

  const TrainingCompletionScreen({
    super.key,
    required this.exerciseId,
    required this.count,
    required this.duration,
    required this.sets,
    required this.repsPerSet,
    required this.onRestart,
    required this.onReturnHome,
  });

  @override
  State<TrainingCompletionScreen> createState() => _TrainingCompletionScreenState();
}

class _TrainingCompletionScreenState extends State<TrainingCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes分${remainingSeconds}秒';
    } else {
      return '${remainingSeconds}秒';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainingModel = Provider.of<TrainingModel>(context);
    final themeModel = Provider.of<ThemeModel>(context);
    final exercise = trainingModel.getExerciseById(widget.exerciseId);
    final color = themeModel.getExerciseColor(widget.exerciseId);

    if (exercise == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with celebration
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Confetti effect
                      Positioned.fill(
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: CustomPaint(
                            painter: ConfettiPainter(),
                          ),
                        ),
                      ),
                      // Main content
                      Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '训练完成！',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Exercise name
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Stats grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              '总次数',
                              '${widget.count}次',
                              Icons.format_list_numbered,
                              color,
                            ),
                            _buildStatItem(
                              '训练时长',
                              _formatDuration(widget.duration),
                              Icons.timer,
                              color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              '训练组数',
                              '${widget.sets}组',
                              Icons.view_list,
                              color,
                            ),
                            _buildStatItem(
                              '每组次数',
                              '${widget.repsPerSet}次',
                              Icons.repeat,
                              color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.onRestart,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: color,
                                  side: BorderSide(color: color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh, size: 20),
                                    SizedBox(width: 8),
                                    Text('重新开始'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onReturnHome,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.home, size: 20),
                                    SizedBox(width: 8),
                                    Text('返回主页'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    final random = Random();

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final color = colors[random.nextInt(colors.length)];
      final sizeConfetti = random.nextDouble() * 8 + 4;

      paint.color = color;

      // Draw confetti as small rectangles
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: sizeConfetti,
          height: sizeConfetti / 2,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Simple random number generator for confetti
class Random {
  int _seed = DateTime.now().millisecondsSinceEpoch;

  double nextDouble() {
    _seed = (_seed * 9301 + 49297) % 233280;
    return _seed / 233280.0;
  }

  int nextInt(int max) {
    return (nextDouble() * max).floor();
  }
}