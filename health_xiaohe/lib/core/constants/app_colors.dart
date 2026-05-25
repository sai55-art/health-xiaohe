import 'package:flutter/material.dart';

/// 奶油暖调 · 哑光鼠尾草 色板。
///
/// 旧常量名(primary/aiBubbleBg/textPrimary…)保留并重映射到新色板,
/// 这样本期未改造的页面不会编译失败、自动呈现新配色。后续逐页清理。
class AppColors {
  AppColors._();

  // ── 主色:哑光鼠尾草 ──
  static const Color primary = Color(0xFF7FB3A8);
  static const Color primaryDark = Color(0xFF6BA095);
  static const Color primaryLight = Color(0xFFE7F0EE);

  // ── 背景:燕麦奶油 ──
  static const Color bgBase = Color(0xFFF6F4EE);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSubtle = Color(0xFFECE8DF);

  // ── 点缀:暖砂 ──
  static const Color accent = Color(0xFFB9A88F);

  // ── 文字:暖墨阶 ──
  static const Color textPrimary = Color(0xFF3D3A34);
  static const Color textSecondary = Color(0xFF736B60);
  static const Color textTertiary = Color(0xFFA89F92);
  static const Color textMuted = Color(0xFFB0A89B);
  static const Color textPlaceholder = Color(0xFFB0A89B);

  // ── 边框 ──
  static const Color border = Color(0xFFECE8DF);
  static const Color borderSoft = Color(0xFFEFEAE0);

  // ── 功能色(暖调) ──
  static const Color success = Color(0xFF6BAE78);
  static const Color warning = Color(0xFFE0A24E);
  static const Color danger = Color(0xFFD9695F);

  // ── 向后兼容别名(旧名 → 新色板) ──
  static const Color secondary = primaryDark;
  static const Color backgroundStart = bgBase;
  static const Color backgroundEnd = bgCard;
  static const Color aiBubbleBg = bgCard;
  static const Color aiBubbleBorder = borderSoft;
  static const Color userBubbleBg = primary;
  static const Color userBubbleText = Color(0xFFFFFFFF);
  static const Color divider = bgSubtle;
  static const Color inputBg = bgCard;

  // 通话页深色背景(本期不改,沿用原值)
  static const Color callBgDark = Color(0xFF1A2A3A);
  static const Color callBgDarkEnd = Color(0xFF0D1520);
}
