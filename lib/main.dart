import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'models/training_model.dart';
import 'models/theme_model.dart';
import 'screens/home_screen.dart';
import 'screens/training_list_screen.dart';
import 'screens/training_plan_screen.dart';
import 'screens/training_records_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/counter_screen.dart';
import 'screens/theme_selection_screen.dart';

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
            return const HomeScreen();
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
          ],
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TrainingModel()),
        ChangeNotifierProvider(create: (context) => ThemeModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return MaterialApp.router(
            title: 'Arch Awaken',
            theme: ThemeData(
              colorScheme: themeModel.currentAppTheme.colorScheme,
              useMaterial3: true,
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}