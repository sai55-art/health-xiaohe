import { router } from '@kit.ArkUI';
import { Prefs } from '../common/storage/Prefs';

/// 启动页：短暂展示品牌后按登录态跳转（对应 Flutter SplashPage）。
@Entry
@Component
struct Splash {
  aboutToAppear(): void {
    setTimeout(() => {
      const target: string = Prefs.isLoggedIn ? 'pages/Main' : 'pages/Login';
      router.replaceUrl({ url: target });
    }, 1200);
  }

  build() {
    Column() {
      Column() {
        Text('🌿').fontSize(56)
      }
      .width(120)
      .height(120)
      .borderRadius(30)
      .backgroundColor($r('app.color.primary'))
      .justifyContent(FlexAlign.Center)

      Text('健康小云')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 24 })

      Text('您的 AI 健康管家')
        .fontSize(14)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_base'))
  }
}
