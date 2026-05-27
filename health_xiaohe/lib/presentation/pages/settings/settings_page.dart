import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';
import 'package:health_xiaohe/core/constants/app_typography.dart';
import 'package:health_xiaohe/core/theme/theme_controller.dart';

/// 设置页。深色模式开关在此切换：
/// 切换时 [ThemeController.setDark] 更新全局调色板并持久化，
/// 本页 setState 立即变色作即时反馈；返回后其余页面经 MainShell 的
/// KeyedSubtree(含 isDark) 已重建为新配色。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark.value;
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('设置', style: AppTypography.titleSans),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: SwitchListTile(
              value: isDark,
              activeColor: AppColors.primary,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
              ),
              title: Text(
                '深色模式',
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
              subtitle: Text(
                isDark ? '暖墨夜间配色' : '奶油暖调日间配色',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
              onChanged: (v) async {
                await ThemeController.setDark(v);
                if (mounted) setState(() {}); // 本页即时变色
              },
            ),
          ),
        ],
      ),
    );
  }
}
