import 'package:flutter/material.dart';

class AppAnimations {
  // 页面过渡动画
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // 卡片悬停动画
  static const Duration cardHoverDuration = Duration(milliseconds: 200);
  static const Curve cardHoverCurve = Curves.easeOut;

  // 按钮点击动画
  static const Duration buttonTapDuration = Duration(milliseconds: 150);
  static const Curve buttonTapCurve = Curves.easeInOut;

  // 列表项动画
  static const Duration listItemDuration = Duration(milliseconds: 250);
  static const Curve listItemCurve = Curves.easeOut;

  // 进度动画
  static const Duration progressDuration = Duration(milliseconds: 500);
  static const Curve progressCurve = Curves.easeOut;

  // 缩放动画
  static Animation<double> createScaleAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: cardHoverCurve,
      ),
    );
  }

  // 淡入动画
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: pageTransitionCurve,
      ),
    );
  }

  // 滑动动画
  static Animation<Offset> createSlideAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: pageTransitionCurve,
      ),
    );
  }

  // 创建交错动画
  static Animation<double> createStaggeredAnimation(
    AnimationController controller,
    int index,
    int totalItems,
  ) {
    final delay = (index / totalItems) * 0.3;
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          1.0,
          curve: listItemCurve,
        ),
      ),
    );
  }
}