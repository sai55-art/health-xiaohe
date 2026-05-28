import { ChatHomeView } from '../views/ChatHomeView';
import { UserProfileView } from '../views/UserProfileView';
import { ChatHistoryView } from '../views/ChatHistoryView';
import { PersonalCenterView } from '../views/PersonalCenterView';

/// 主框架（对应 Flutter MainShell）：Tabs 底部 4 tab，套奶油暖调。
@Entry
@Component
struct Main {
  @State index: number = 0;

  @Builder
  tabBuilder(idx: number, symbol: Resource, label: string) {
    Column() {
      SymbolGlyph(symbol)
        .fontSize(24)
        .fontColor([this.index === idx ? $r('app.color.primary') : $r('app.color.text_tertiary')])
      Text(label)
        .fontSize(11)
        .margin({ top: 2 })
        .fontColor(this.index === idx ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .fontWeight(this.index === idx ? FontWeight.Medium : FontWeight.Normal)
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.index }) {
      TabContent() {
        ChatHomeView()
      }.tabBar(this.tabBuilder(0, $r('sys.symbol.message'), '咨询'))

      TabContent() {
        UserProfileView()
      }.tabBar(this.tabBuilder(1, $r('sys.symbol.heart'), '画像'))

      TabContent() {
        ChatHistoryView()
      }.tabBar(this.tabBuilder(2, $r('sys.symbol.clock'), '历史'))

      TabContent() {
        PersonalCenterView()
      }.tabBar(this.tabBuilder(3, $r('sys.symbol.person'), '我的'))
    }
    .barHeight(64)
    .barBackgroundColor($r('app.color.bg_card'))
    .scrollable(false)
    .onChange((i: number) => { this.index = i; })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_base'))
  }
}
