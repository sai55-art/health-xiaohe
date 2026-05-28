// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
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
