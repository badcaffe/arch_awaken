import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/theme_model.dart';
import 'training_plan_screen.dart';
import 'training_list_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TrainingPlanScreen(), // 今日
    const TrainingListScreen(), // 项目
    const AchievementsScreen(),  // 成就
    const ProfileScreen(),      // 我的
  ];

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.today),
              label: '今日',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: '项目',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: '成就',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '我的',
            ),
          ],
          selectedItemColor: themeModel.currentTheme == ThemeScheme.dark
              ? const Color(0xFFD0D0D0) // Light gray for dark theme
              : themeModel.currentAppTheme.colorScheme.primary,
          unselectedItemColor: Colors.grey.withAlpha(153), // Lighter gray for better contrast
          backgroundColor: Theme.of(context).colorScheme.surface,
          type: BottomNavigationBarType.fixed,
          enableFeedback: false,
        ),
      ),
    );
  }
}