import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Header
          const SizedBox(height: 16),
          // App Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Image(
              image: AssetImage('assets/images/logo.png'),
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(height: 24),
          // App Name
          const Text(
            '足弓觉醒',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Version
          Text(
            '版本 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Settings section
          Container(
            decoration: AppTheme.cardDecoration(context),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.list,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    '今日项目',
                    style: AppTheme.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '选择和排序今日训练项目',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    context.go('/today-exercises-selection');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.flag,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    '训练目标',
                    style: AppTheme.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '设置项目训练目标',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    context.go('/goal-setting');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    '项目设置',
                    style: AppTheme.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '设置通用训练参数，如休息时长等',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    context.go('/project-settings');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.palette,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    '配色主题',
                    style: AppTheme.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '选择应用主题颜色',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    context.go('/theme-selection');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    '关于应用',
                    style: AppTheme.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '查看应用版本信息',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    context.go('/about');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}