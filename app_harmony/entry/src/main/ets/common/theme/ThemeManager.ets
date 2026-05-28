// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import { ConfigurationConstant, common } from '@kit.AbilityKit';
import { Prefs } from '../storage/Prefs';

/// 深色模式管理。鸿蒙原生方案：通过 setColorMode 切换深/浅，
/// 系统自动改用 resources/dark/ 下的颜色资源重绘所有 $r('app.color.*')，
/// 无需像 Flutter 端那样手动重建 widget 树。偏好持久化到 Prefs。
export class ThemeManager {
  static isDark(): boolean {
    return Prefs.getBool(Prefs.KEY_DARK, false);
  }

  /// 切换并持久化。context 由 UI 组件 getContext(this) 传入。
  static apply(context: common.UIAbilityContext, dark: boolean): void {
    context.getApplicationContext().setColorMode(
      dark
        ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK
        : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
    );
    Prefs.putBool(Prefs.KEY_DARK, dark);
  }

  /// 启动时按持久化偏好恢复（在 EntryAbility.onCreate 调用）。
  static restore(context: common.UIAbilityContext): void {
    ThemeManager.apply(context, ThemeManager.isDark());
  }
}
