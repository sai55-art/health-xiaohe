// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:flutter/material.dart';
import 'package:health_xiaohe/app.dart';
import 'package:health_xiaohe/core/theme/theme_controller.dart';
import 'package:health_xiaohe/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  ThemeController.initFromStorage(); // 应用持久化的深色模式偏好
  runApp(const HealthXiaoheApp());
}
