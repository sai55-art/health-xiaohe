import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ThemeManager } from '../common/theme/ThemeManager';
import { R, Space, FS } from '../common/theme/Tokens';

/// 设置页（对应 Flutter settings_page）：深色模式开关。
/// 鸿蒙 setColorMode 切换后系统自动改用 dark/ 资源重绘所有 $r 颜色，
/// 本页与全 App 立即变色，无需手动重建。
@Entry
@Component
struct Settings {
  @State dark: boolean = false;

  aboutToAppear(): void {
    this.dark = ThemeManager.isDark();
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(22).fontColor([$r('app.color.text_secondary')])
          .onClick(() => { router.back(); })
        Text('设置')
          .fontSize(FS.title).fontColor($r('app.color.text_primary'))
          .margin({ left: Space.md })
      }
      .width('100%').padding(Space.md).alignItems(VerticalAlign.Center)

      // 深色模式开关
      Row() {
        SymbolGlyph(this.dark ? $r('sys.symbol.moon') : $r('sys.symbol.sun_max'))
          .fontSize(20).fontColor([$r('app.color.primary_dark')]).margin({ right: Space.md })
        Column() {
          Text('深色模式').fontSize(FS.body).fontColor($r('app.color.text_primary'))
          Text(this.dark ? '暖墨夜间配色' : '奶油暖调日间配色')
            .fontSize(FS.caption).fontColor($r('app.color.text_tertiary')).margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.dark })
          .selectedColor($r('app.color.primary'))
          .onChange((isOn: boolean) => {
            this.dark = isOn;
            const ctx = getContext(this) as common.UIAbilityContext;
            ThemeManager.apply(ctx, isOn);
          })
      }
      .width('100%').padding(Space.md)
      .backgroundColor($r('app.color.bg_card')).borderRadius(R.card)
      .border({ width: 1, color: $r('app.color.border_soft') })
      .margin(Space.lg)
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_base'))
  }
}
