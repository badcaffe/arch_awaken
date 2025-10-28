import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'models/training_model.dart';
import 'models/theme_model.dart';
import 'models/goal_model.dart';
import 'models/today_exercises_model.dart';
import 'screens/main_tab_screen.dart';
import 'screens/training_list_screen.dart';
import 'screens/training_plan_screen.dart';
import 'screens/training_records_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/counter_screen.dart';
import 'screens/theme_selection_screen.dart';
import 'screens/goal_setting_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/today_exercises_selection_screen.dart';

void main() {
  runApp(const ArchAwakenApp());
}

class ArchAwakenApp extends StatelessWidget {
  const ArchAwakenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const MainTabScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'training-list',
              builder: (BuildContext context, GoRouterState state) {
                return const TrainingListScreen();
              },
            ),
            GoRoute(
              path: 'training-plan',
              builder: (BuildContext context, GoRouterState state) {
                return const TrainingPlanScreen();
              },
            ),
            GoRoute(
              path: 'training-records',
              builder: (BuildContext context, GoRouterState state) {
                return const TrainingRecordsScreen();
              },
            ),
            GoRoute(
              path: 'timer/:exerciseId',
              builder: (BuildContext context, GoRouterState state) {
                final exerciseId = state.pathParameters['exerciseId']!;
                return TimerScreen(exerciseId: exerciseId);
              },
            ),
            GoRoute(
              path: 'counter/:exerciseId',
              builder: (BuildContext context, GoRouterState state) {
                final exerciseId = state.pathParameters['exerciseId']!;
                return CounterScreen(exerciseId: exerciseId);
              },
            ),
            GoRoute(
              path: 'theme-selection',
              builder: (BuildContext context, GoRouterState state) {
                return const ThemeSelectionScreen();
              },
            ),
            GoRoute(
              path: 'goal-setting',
              builder: (BuildContext context, GoRouterState state) {
                return const GoalSettingScreen();
              },
            ),
            GoRoute(
              path: 'today-exercises-selection',
              builder: (BuildContext context, GoRouterState state) {
                return const TodayExercisesSelectionScreen();
              },
            ),
          ],
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TrainingModel()),
        ChangeNotifierProvider(create: (context) => ThemeModel()),
        ChangeNotifierProvider(create: (context) => GoalModel()),
        ChangeNotifierProvider(create: (context) => TodayExercisesModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return MaterialApp.router(
            title: 'Arch Awaken',
            theme: ThemeData(
              colorScheme: themeModel.currentAppTheme.colorScheme,
              useMaterial3: true,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}