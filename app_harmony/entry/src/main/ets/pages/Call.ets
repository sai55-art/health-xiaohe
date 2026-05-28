import { router, promptAction } from '@kit.ArkUI';
import { Space, FS } from '../common/theme/Tokens';

/// 语音通话页（对应 Flutter call_page）。恒定深色背景的通话界面。
/// 注：DashScope Realtime 实时音频流(WebSocket + PCM)在 ArkTS 端适配成本高，
/// 此处先还原 UI 与交互骨架，实时语音为占位，可后续接入 @ohos.multimedia.audio。
@Entry
@Component
struct Call {
  @State status: string = '语音通话演示（实时音频待接入）';
  @State muted: boolean = false;

  build() {
    Column() {
      Blank().height(80)

      // AI 头像
      Column() {
        Text('🌿').fontSize(64)
      }
      .width(140).height(140).borderRadius(70)
      .backgroundColor('#22FFFFFF')
      .justifyContent(FlexAlign.Center)

      Text('健康小云')
        .fontSize(24).fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF').margin({ top: Space.lg })

      Text(this.status)
        .fontSize(FS.body).fontColor('#B0C4D4')
        .margin({ top: Space.sm })

      Blank()

      // 控制按钮
      Row() {
        this.controlButton(this.muted ? '🔇' : '🎤', '#33FFFFFF', () => {
          this.muted = !this.muted;
          promptAction.showToast({ message: this.muted ? '已静音' : '已取消静音' });
        })
        this.controlButton('📞', '#D9695F', () => {
          router.back();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 60 })
    }
    .width('100%').height('100%')
    .backgroundColor('#1A2A3A')
  }

  @Builder
  controlButton(icon: string, bg: string, onTap: () => void) {
    Column() {
      Text(icon).fontSize(28)
    }
    .width(64).height(64).borderRadius(32)
    .backgroundColor(bg)
    .justifyContent(FlexAlign.Center)
    .onClick(onTap)
  }
}
