import 'package:flutter/animation.dart';

/// 动效 token:静润(强缓出、无回弹)+ stagger。
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);

  static const Cubic calm = Cubic(0.22, 0.61, 0.36, 1);

  static const double entranceOffset = 16;
  static const double pageOffset = 12;
  static const Duration staggerStep = Duration(milliseconds: 60);
  static const int staggerMaxIndex = 5;
}
