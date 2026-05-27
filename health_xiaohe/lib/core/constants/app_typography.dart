import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';

/// 字体 token：宋体大标题 + Fraunces 英数/数字 + 系统正文。
///
/// 各 TextStyle 为 **getter**（非 const）：颜色引用动态的 [AppColors]，
/// 因此随亮/暗主题自动切换。引用语法 `AppTypography.body` 不变。
class AppTypography {
  AppTypography._();

  static const String serif = 'NotoSerifSC';
  static const String fraunces = 'Fraunces';

  static TextStyle get displaySerif => TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w600,
        fontSize: 26,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSerif => TextStyle(
        fontFamily: serif,
        fontWeight: FontWeight.w500,
        fontSize: 20,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get overline => TextStyle(
        fontFamily: fraunces,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 2,
        color: AppColors.textTertiary,
      );

  static TextStyle get titleSans => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.6,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get numeric => TextStyle(
        fontFamily: fraunces,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
