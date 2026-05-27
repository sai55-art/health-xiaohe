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
