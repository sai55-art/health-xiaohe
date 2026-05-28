// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_xiaohe/core/constants/app_motion.dart';

/// 统一页面过渡:淡入 + 轻上浮(静润曲线)。
CustomTransitionPage<void> fadeUpPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppMotion.base,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.calm);
      return FadeTransition(
        opacity: curved,
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, c) => Transform.translate(
            offset: Offset(0, (1 - curved.value) * AppMotion.pageOffset),
            child: c,
          ),
          child: child,
        ),
      );
    },
  );
}
