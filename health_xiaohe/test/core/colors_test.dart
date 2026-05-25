import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';

void main() {
  test('新语义色值正确', () {
    expect(AppColors.primary, const Color(0xFF7FB3A8));
    expect(AppColors.bgBase, const Color(0xFFF6F4EE));
    expect(AppColors.bgSubtle, const Color(0xFFECE8DF));
    expect(AppColors.accent, const Color(0xFFB9A88F));
    expect(AppColors.textPrimary, const Color(0xFF3D3A34));
  });

  test('旧常量名重映射到新色板(向后兼容,未改页面不崩)', () {
    expect(AppColors.userBubbleBg, AppColors.primary);
    expect(AppColors.aiBubbleBg, AppColors.bgCard);
    expect(AppColors.inputBg, isNotNull);
    expect(AppColors.divider, AppColors.bgSubtle);
  });
}
