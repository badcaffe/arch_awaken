import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/theme_model.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final themeOptions = themeModel.getThemeOptions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('配色主题'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择您喜欢的配色主题',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '配色主题将立即生效',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: themeOptions.length,
                itemBuilder: (context, index) {
                  final option = themeOptions[index];
                  final theme = option['theme'] as ThemeScheme;
                  final name = option['name'] as String;
                  final primaryColor = option['primaryColor'] as Color;
                  final description = option['description'] as String;
                  final isSelected = themeModel.currentTheme == theme;

                  // For dark theme, use a contrasting color when selected
                  final effectiveColor = (theme == ThemeScheme.dark && isSelected)
                      ? const Color(0xFF757575) // Use gray for contrast when dark theme is selected
                      : primaryColor;

                  return Card(
                    elevation: 0,
                    color: isSelected ? effectiveColor.withAlpha(5) : Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? effectiveColor : Theme.of(context).dividerColor,
                        width: isSelected ? 1 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: effectiveColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? effectiveColor : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: effectiveColor,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        themeModel.changeTheme(theme);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '配色预览',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildColorPreview(themeModel.getExerciseColor('ball_tiptoe'), '夹球踮脚'),
                        _buildColorPreview(themeModel.getExerciseColor('yoga_brick_tiptoe'), '瑜伽砖踮脚'),
                        _buildColorPreview(themeModel.getExerciseColor('frog_pose'), '青蛙趴'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}