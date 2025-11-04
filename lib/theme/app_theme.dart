import 'package:flutter/material.dart';

class AppTheme {
  // 卡片样式
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // 按钮样式
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      elevation: 0,
    );
  }

  // 进度条样式
  static LinearProgressIndicator progressIndicator({
    required double value,
    required BuildContext context,
  }) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      color: Theme.of(context).colorScheme.primary,
      minHeight: 8,
      borderRadius: BorderRadius.circular(8),
    );
  }

  // 文字样式
  static TextStyle headlineSmall(BuildContext context) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }
}