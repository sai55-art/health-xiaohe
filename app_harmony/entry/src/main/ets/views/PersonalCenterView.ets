import { router, promptAction } from '@kit.ArkUI';
import { Prefs } from '../common/storage/Prefs';
import { R, Space, FS } from '../common/theme/Tokens';

/// 我的（对应 Flutter personal_center_page）：用户头部 + 菜单卡片 + 退出。
@Component
export struct PersonalCenterView {
  @State nickname: string = '';
  @State phone: string = '';

  aboutToAppear(): void {
    this.nickname = Prefs.getString(Prefs.KEY_NICKNAME, '用户');
    this.phone = Prefs.getString(Prefs.KEY_PHONE, '');
  }

  private maskPhone(p: string): string {
    if (p.length >= 11) {
      return p.substring(0, 3) + '****' + p.substring(7);
    }
    return p;
  }

  @Builder
  menuItem(icon: Resource, title: string, onTap: () => void) {
    Row() {
      SymbolGlyph(icon).fontSize(20).fontColor([$r('app.color.text_secondary')]).margin({ right: Space.md })
      Text(title).fontSize(FS.body).fontColor($r('app.color.text_primary')).layoutWeight(1)
      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(16).fontColor([$r('app.color.text_muted')])
    }
    .width('100%')
    .padding(Space.md)
    .onClick(onTap)
  }

  build() {
    Scroll() {
      Column() {
        // 头部
        Row() {
          Column() {
            Text('🌿').fontSize(32)
          }
          .width(64).height(64).borderRadius(32)
          .backgroundColor($r('app.color.bg_card'))
          .justifyContent(FlexAlign.Center)

          Column() {
            Text(this.nickname)
              .fontSize(20).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_primary'))
            Text(this.maskPhone(this.phone))
              .fontSize(FS.caption)
              .fontColor($r('app.color.on_primary'))
              .opacity(0.85)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: Space.md })
        }
        .width('100%')
        .padding({ left: Space.lg, right: Space.lg, top: Space.xl, bottom: Space.xl })
        .backgroundColor($r('app.color.primary'))

        Column() {
          // 设置卡片
          Column() {
            this.menuItem($r('sys.symbol.gearshape'), '设置', () => { router.pushUrl({ url: 'pages/Settings' }); })
            Divider().color($r('app.color.bg_subtle')).margin({ left: Space.md })
            this.menuItem($r('sys.symbol.lock'), '账号安全', () => {
              promptAction.showToast({ message: '功能开发中' });
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(R.card)
          .border({ width: 1, color: $r('app.color.border_soft') })
          .margin({ top: Space.md })

          // 关于卡片
          Column() {
            this.menuItem($r('sys.symbol.info_circle'), '关于我们', () => {
              promptAction.showToast({ message: '健康小云 · 鸿蒙版 v1.0.0' });
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(R.card)
          .border({ width: 1, color: $r('app.color.border_soft') })
          .margin({ top: Space.md })

          Button('退出登录')
            .width('100%').height(52)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.danger'))
            .borderRadius(R.input)
            .border({ width: 2, color: $r('app.color.danger') })
            .margin({ top: Space.lg })
            .onClick(() => {
              Prefs.clearAuth();
              router.replaceUrl({ url: 'pages/Login' });
            })
        }
        .width('100%')
        .padding(Space.lg)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_base'))
    .align(Alignment.Top)
  }
}
