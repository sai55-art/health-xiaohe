import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';

/// 字体 token:宋体大标题 + Fraunces 英数/数字 + 系统正文。
class AppTypography {
  AppTypography._();

  static const String serif = 'NotoSerifSC';
  static const String fraunces = 'Fraunces';

  static const TextStyle displaySerif = TextStyle(
    fontFamily: serif,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSerif = TextStyle(
    fontFamily: serif,
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fraunces,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 2,
    color: AppColors.textTertiary,
  );

  static const TextStyle titleSans = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle numeric = TextStyle(
    fontFamily: fraunces,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
