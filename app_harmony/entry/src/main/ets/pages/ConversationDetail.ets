// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import { router } from '@kit.ArkUI';
import { ApiClient, ApiResp } from '../common/net/ApiClient';
import { Api } from '../common/net/Api';
import { ChatMessage } from '../common/models/Models';
import { MarkdownText } from '../components/MarkdownText';
import { R, Space, FS } from '../common/theme/Tokens';

interface DetailParams {
  id?: string;
  title?: string;
}

interface DetailResp {
  messages?: ChatMessage[];
  title?: string;
}

/// 对话详情（对应 Flutter conversation_detail_page）：只读消息列表。
@Entry
@Component
struct ConversationDetail {
  @State title: string = '对话详情';
  @State messages: ChatMessage[] = [];
  @State loading: boolean = true;
  private convId: string = '';

  aboutToAppear(): void {
    const params: DetailParams = router.getParams() as DetailParams;
    if (params) {
      this.convId = params.id ?? '';
      this.title = params.title ?? '对话详情';
    }
    this.load();
  }

  private async load(): Promise<void> {
    if (this.convId.length === 0) {
      this.loading = false;
      return;
    }
    try {
      const resp: ApiResp = await ApiClient.get(Api.conversationDetail(this.convId), true);
      if (resp.code === 200) {
        const d: DetailResp = JSON.parse(resp.body) as DetailResp;
        this.messages = d.messages ?? [];
      }
    } catch (e) {
      // 静默
    } finally {
      this.loading = false;
    }
  }

  @Builder
  bubble(msg: ChatMessage) {
    Row() {
      if (msg.role === 'user') {
        Text(msg.content)
          .fontSize(FS.body)
          .fontColor($r('app.color.on_primary'))
          .backgroundColor($r('app.color.primary'))
          .borderRadius(R.bubble)
          .padding(Space.md)
          .constraintSize({ maxWidth: '80%' })
      } else {
        Column() {
          MarkdownText({ content: msg.content })
        }
        .backgroundColor($r('app.color.bg_card'))
        .borderRadius(R.bubble)
        .padding(Space.md)
        .constraintSize({ maxWidth: '86%' })
      }
    }
    .width('100%')
    .justifyContent(msg.role === 'user' ? FlexAlign.End : FlexAlign.Start)
    .margin({ bottom: Space.sm })
  }

  build() {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(22).fontColor([$r('app.color.text_secondary')])
          .onClick(() => { router.back(); })
        Text(this.title)
          .fontSize(FS.title).fontColor($r('app.color.text_primary'))
          .margin({ left: Space.md })
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%').padding(Space.md).alignItems(VerticalAlign.Center)

      if (this.loading) {
        LoadingProgress().width(40).height(40).color($r('app.color.primary')).margin({ top: Space.xl })
      } else {
        List() {
          ForEach(this.messages, (msg: ChatMessage) => {
            ListItem() {
              this.bubble(msg)
            }
          }, (msg: ChatMessage, idx: number) => idx.toString())
        }
        .layoutWeight(1).width('100%')
        .padding({ left: Space.md, right: Space.md })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_base'))
  }
}
