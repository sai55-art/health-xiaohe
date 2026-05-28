// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:flutter/material.dart';

/// 奶油暖调 · 哑光鼠尾草 色板（支持亮/暗双模式）。
///
/// 字段由原先的 `static const` 改为**动态 getter**，运行时随 [AppColors.mode]
/// 在亮/暗两套调色板间整体切换。好处：全项目对 `AppColors.xxx` 的引用零改动，
/// 切换主题后所有页面自动呈现对应配色。
///
/// 代价：这些字段不再是编译期常量，任何用到它们的 `const` 构造都要去掉 `const`。
/// 切换入口见 `core/theme/theme_controller.dart`。
class _Palette {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color bgBase;
  final Color bgCard;
  final Color bgSubtle;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color textPlaceholder;
  final Color border;
  final Color borderSoft;
  final Color success;
  final Color warning;
  final Color danger;

  const _Palette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.bgBase,
    required this.bgCard,
    required this.bgSubtle,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.textPlaceholder,
    required this.border,
    required this.borderSoft,
    required this.success,
    required this.warning,
    required this.danger,
  });
}

/// 亮色：奶油暖调原色板。
const _Palette _light = _Palette(
  primary: Color(0xFF7FB3A8),
  primaryDark: Color(0xFF6BA095),
  primaryLight: Color(0xFFE7F0EE),
  bgBase: Color(0xFFF6F4EE),
  bgCard: Color(0xFFFFFFFF),
  bgSubtle: Color(0xFFECE8DF),
  accent: Color(0xFFB9A88F),
  textPrimary: Color(0xFF3D3A34),
  textSecondary: Color(0xFF736B60),
  textTertiary: Color(0xFFA89F92),
  textMuted: Color(0xFFB0A89B),
  textPlaceholder: Color(0xFFB0A89B),
  border: Color(0xFFECE8DF),
  borderSoft: Color(0xFFEFEAE0),
  success: Color(0xFF6BAE78),
  warning: Color(0xFFE0A24E),
  danger: Color(0xFFD9695F),
);

/// 暗色：暖墨底 + 提亮鼠尾草，沿用暖调（非纯黑/纯白）。
const _Palette _dark = _Palette(
  primary: Color(0xFF8FC3B7),
  primaryDark: Color(0xFFA7D2C8),
  primaryLight: Color(0xFF2A3A36),
  bgBase: Color(0xFF1C1A17),
  bgCard: Color(0xFF26231E),
  bgSubtle: Color(0xFF332F28),
  accent: Color(0xFFC9B89D),
  textPrimary: Color(0xFFEDE7DB),
  textSecondary: Color(0xFFB8AE9F),
  textTertiary: Color(0xFF8C8377),
  textMuted: Color(0xFF726A5F),
  textPlaceholder: Color(0xFF726A5F),
  border: Color(0xFF3A352D),
  borderSoft: Color(0xFF332F28),
  success: Color(0xFF7BBE88),
  warning: Color(0xFFE5B265),
  danger: Color(0xFFE07A70),
);

enum AppBrightness { light, dark }

class AppColors {
  AppColors._();

  /// 当前主题模式。由 theme_controller 在切换时设置；UI 不要直接写它。
  static AppBrightness mode = AppBrightness.light;

  static bool get isDark => mode == AppBrightness.dark;

  static _Palette get _p => isDark ? _dark : _light;

  // ── 主色 ──
  static Color get primary => _p.primary;
  static Color get primaryDark => _p.primaryDark;
  static Color get primaryLight => _p.primaryLight;

  // ── 背景 ──
  static Color get bgBase => _p.bgBase;
  static Color get bgCard => _p.bgCard;
  static Color get bgSubtle => _p.bgSubtle;

  // ── 点缀 ──
  static Color get accent => _p.accent;

  // ── 文字 ──
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textTertiary => _p.textTertiary;
  static Color get textMuted => _p.textMuted;
  static Color get textPlaceholder => _p.textPlaceholder;

  // ── 边框 ──
  static Color get border => _p.border;
  static Color get borderSoft => _p.borderSoft;

  // ── 功能色 ──
  static Color get success => _p.success;
  static Color get warning => _p.warning;
  static Color get danger => _p.danger;

  // ── 向后兼容别名（旧名 → 当前调色板） ──
  static Color get secondary => _p.primaryDark;
  static Color get backgroundStart => _p.bgBase;
  static Color get backgroundEnd => _p.bgCard;
  static Color get aiBubbleBg => _p.bgCard;
  static Color get aiBubbleBorder => _p.borderSoft;
  static Color get userBubbleBg => _p.primary;
  static Color get divider => _p.bgSubtle;
  static Color get inputBg => _p.bgCard;

  /// 用户气泡文字：主色之上恒为白，两模式一致。
  static const Color userBubbleText = Color(0xFFFFFFFF);

  /// 通话页恒定深色背景（与主题模式无关，始终深色）。
  static const Color callBgDark = Color(0xFF1A2A3A);
  static const Color callBgDarkEnd = Color(0xFF0D1520);
}
