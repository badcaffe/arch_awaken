import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/theme_model.dart' hide AppTheme;
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User info section
          Container(
            decoration: AppTheme.cardDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: themeModel.currentAppTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeModel.currentAppTheme.colorScheme.primary,
                          themeModel.currentAppTheme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: themeModel.currentAppTheme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '训练者',
                          style: AppTheme.headlineSmall(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '坚持训练，足弓觉醒',
                          style: AppTheme.bodyMedium(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          // Settings section
          Text(
            '设置',
            style: AppTheme.headlineSmall(context).copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
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