// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';
import 'package:health_xiaohe/core/storage/local_storage.dart';
import 'package:health_xiaohe/injection.dart';

/// 全局深色模式控制器。
///
/// - [isDark] 是一个 ValueNotifier，`app.dart` 监听它重建 MaterialApp，
///   从而让基于动态 [AppColors] 的主题与所有页面重新求值。
/// - 切换时同步更新 [AppColors.mode] 并持久化到 [LocalStorage]。
class ThemeController {
  ThemeController._();

  static final ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

  /// 启动时从本地存储读取并应用（在 runApp 前调用）。
  static void initFromStorage() {
    final dark = getIt<LocalStorage>().getDarkMode();
    isDark.value = dark;
    AppColors.mode = dark ? AppBrightness.dark : AppBrightness.light;
  }

  /// 设置并持久化深色模式。
  static Future<void> setDark(bool dark) async {
    AppColors.mode = dark ? AppBrightness.dark : AppBrightness.light;
    isDark.value = dark; // 触发 app.dart 重建
    await getIt<LocalStorage>().saveDarkMode(dark);
  }

  static Future<void> toggle() => setDark(!isDark.value);
}
