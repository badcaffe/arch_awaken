import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeScheme {
  ocean,     // 海洋色调
  sunset,    // 日落色调
  forest,    // 森林色调
  lavender,  // 薰衣草色调
  dark,      // 暗黑色调
}

class AppTheme {
  final String name;
  final ColorScheme colorScheme;
  final Map<String, Color> exerciseColors;

  const AppTheme({
    required this.name,
    required this.colorScheme,
    required this.exerciseColors,
  });
}

class ThemeModel extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';

  ThemeScheme _currentTheme = ThemeScheme.ocean;

  ThemeScheme get currentTheme => _currentTheme;

  final Map<ThemeScheme, AppTheme> _themes = {
    ThemeScheme.sunset: AppTheme(
      name: '日落',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE65100),
        brightness: Brightness.light,
      ),
      exerciseColors: {
        'ball_tiptoe': const Color(0xFFE65100), // Deep orange
        'yoga_brick_tiptoe': const Color(0xFFF57C00), // Orange
        'yoga_brick_ball_pickup': const Color(0xFFFF9800), // Bright orange
        'frog_pose': const Color(0xFFFFB74D), // Light orange
        'glute_bridge': const Color(0xFFD32F2F), // Red
        'stretching': const Color(0xFF7B1FA2), // Purple
        'foot_ball_rolling': const Color(0xFFFF5722), // Deep orange-red
      },
    ),
    ThemeScheme.forest: AppTheme(
      name: '森林',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        brightness: Brightness.light,
      ),
      exerciseColors: {
        'ball_tiptoe': const Color(0xFF2E7D32), // Deep green
        'yoga_brick_tiptoe': const Color(0xFF388E3C), // Green
        'yoga_brick_ball_pickup': const Color(0xFF43A047), // Bright green
        'frog_pose': const Color(0xFF66BB6A), // Light green
        'glute_bridge': const Color(0xFF1976D2), // Blue
        'stretching': const Color(0xFF7B1FA2), // Purple
        'foot_ball_rolling': const Color(0xFF4CAF50), // Bright green
      },
    ),
    ThemeScheme.ocean: AppTheme(
      name: '海洋',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.light,
      ),
      exerciseColors: {
        'ball_tiptoe': const Color(0xFF1565C0), // Deep blue
        'yoga_brick_tiptoe': const Color(0xFF1976D2), // Blue
        'yoga_brick_ball_pickup': const Color(0xFF2196F3), // Bright blue
        'frog_pose': const Color(0xFF64B5F6), // Light blue
        'glute_bridge': const Color(0xFF0097A7), // Teal
        'stretching': const Color(0xFF9575CD), // Lavender
        'foot_ball_rolling': const Color(0xFF03A9F4), // Light blue
      },
    ),
    ThemeScheme.lavender: AppTheme(
      name: '薰衣草',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7B1FA2),
        brightness: Brightness.light,
      ),
      exerciseColors: {
        'ball_tiptoe': const Color(0xFF7B1FA2), // Deep purple
        'yoga_brick_tiptoe': const Color(0xFF8E24AA), // Purple
        'yoga_brick_ball_pickup': const Color(0xFF9C27B0), // Bright purple
        'frog_pose': const Color(0xFFBA68C8), // Light purple
        'glute_bridge': const Color(0xFFE91E63), // Pink
        'stretching': const Color(0xFF3F51B5), // Indigo
        'foot_ball_rolling': const Color(0xFF9C27B0), // Bright purple
      },
    ),
    ThemeScheme.dark: AppTheme(
      name: '暗黑',
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF1A1F2E), // Dark blue-gray for app bars
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFF2D2D2D),
        onPrimaryContainer: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF757575), // Gray accent
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFF505050),
        onSecondaryContainer: const Color(0xFFFFFFFF),
        tertiary: const Color(0xFF909090), // Light gray accent
        onTertiary: const Color(0xFF000000),
        tertiaryContainer: const Color(0xFF606060),
        onTertiaryContainer: const Color(0xFFFFFFFF),
        surface: const Color(0xFF121212), // Dark surface
        onSurface: const Color(0xFFFFFFFF),
        surfaceContainerHighest: const Color(0xFF1E1E1E),
        onSurfaceVariant: const Color(0xFFB0B0B0),
        error: const Color(0xFFCF6679),
        onError: const Color(0xFF000000),
        errorContainer: const Color(0xFF8A1C3A),
        onErrorContainer: const Color(0xFFFFFFFF),
        outline: const Color(0xFF6D6D6D),
        outlineVariant: const Color(0xFF404040),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: const Color(0xFFFFFFFF),
        onInverseSurface: const Color(0xFF121212),
        inversePrimary: const Color(0xFF1E1E1E),
        surfaceTint: const Color(0xFF757575),
      ),
      exerciseColors: {
        'ball_tiptoe': const Color(0xFFB0B0B0), // Light gray
        'yoga_brick_tiptoe': const Color(0xFF909090), // Medium gray
        'yoga_brick_ball_pickup': const Color(0xFF707070), // Dark gray
        'frog_pose': const Color(0xFF505050), // Very dark gray
        'glute_bridge': const Color(0xFF808080), // Standard gray
        'stretching': const Color(0xFF606060), // Medium-dark gray
        'foot_ball_rolling': const Color(0xFFA0A0A0), // Light gray
      },
    ),
  };

  ThemeModel() {
    _loadTheme();
  }

  AppTheme get currentAppTheme => _themes[_currentTheme]!;

  Color getExerciseColor(String exerciseId) {
    return _themes[_currentTheme]!.exerciseColors[exerciseId] ?? Colors.grey;
  }

  void changeTheme(ThemeScheme theme) {
    _currentTheme = theme;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme = ThemeScheme.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _currentTheme.index);
  }

  List<Map<String, dynamic>> getThemeOptions() {
    return [
      {
        'theme': ThemeScheme.ocean,
        'name': '海洋',
        'primaryColor': const Color(0xFF1565C0),
        'description': '清新的蓝色调，带来海洋般的宁静',
      },
      {
        'theme': ThemeScheme.sunset,
        'name': '日落',
        'primaryColor': const Color(0xFFE65100),
        'description': '温暖的橙红色调，如同日落时分',
      },
      {
        'theme': ThemeScheme.forest,
        'name': '森林',
        'primaryColor': const Color(0xFF2E7D32),
        'description': '自然的绿色调，带来森林般的宁静',
      },
      {
        'theme': ThemeScheme.lavender,
        'name': '薰衣草',
        'primaryColor': const Color(0xFF7B1FA2),
        'description': '浪漫的紫色调，如同薰衣草花田',
      },
      {
        'theme': ThemeScheme.dark,
        'name': '暗黑',
        'primaryColor': const Color(0xFF121212),
        'description': '深邃的暗黑色调，适合夜间使用',
      },
    ];
  }
}