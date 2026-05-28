// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import { router, promptAction } from '@kit.ArkUI';
import { ApiClient, ApiResp } from '../common/net/ApiClient';
import { Api } from '../common/net/Api';
import { Conversation } from '../common/models/Models';
import { R, Space, FS } from '../common/theme/Tokens';

interface ConvListResp {
  conversations?: Conversation[];
  items?: Conversation[];
}

/// 历史页（对应 Flutter chat_history_page）：对话列表，点击进详情。
@Component
export struct ChatHistoryView {
  @State items: Conversation[] = [];
  @State loading: boolean = true;
  @State err: string = '';

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    this.loading = true;
    this.err = '';
    try {
      const resp: ApiResp = await ApiClient.get(Api.conversations, true);
      if (resp.code === 200) {
        // 后端可能直接返回数组，或包在 conversations/items 字段里——都兼容
        const trimmed: string = resp.body.trim();
        if (trimmed.startsWith('[')) {
          this.items = JSON.parse(trimmed) as Conversation[];
        } else {
          const wrap: ConvListResp = JSON.parse(trimmed) as ConvListResp;
          this.items = wrap.conversations ?? wrap.items ?? [];
        }
      } else {
        this.err = '加载失败（' + resp.code + '）';
      }
    } catch (e) {
      this.err = '网络错误，请检查后端连接';
    } finally {
      this.loading = false;
    }
  }

  private async deleteConv(id: string): Promise<void> {
    const resp: ApiResp = await ApiClient.del(Api.conversationDetail(id), true);
    if (resp.code === 200 || resp.code === 204) {
      promptAction.showToast({ message: '已删除' });
      this.load();
    } else {
      promptAction.showToast({ message: '删除失败(' + resp.code + ')' });
    }
  }

  private async regenTitle(id: string): Promise<void> {
    promptAction.showToast({ message: '重新生成中…' });
    const empty: Record<string, string> = {};
    const resp: ApiResp = await ApiClient.post(Api.conversationRegenTitle(id), empty, true);
    if (resp.code === 200) {
      this.load();
    } else {
      promptAction.showToast({ message: '失败(' + resp.code + ')' });
    }
  }

  build() {
    Column() {
      Text('对话历史')
        .fontSize(FS.display).fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%').padding({ left: Space.lg, right: Space.lg, top: Space.lg })

      if (this.loading) {
        LoadingProgress().width(40).height(40).color($r('app.color.primary')).margin({ top: Space.xl })
      } else if (this.err.length > 0) {
        Text(this.err).fontSize(FS.body).fontColor($r('app.color.text_muted')).margin({ top: Space.xl })
      } else if (this.items.length === 0) {
        Text('暂无对话历史').fontSize(FS.body).fontColor($r('app.color.text_muted')).margin({ top: Space.xl })
      } else {
        List() {
          ForEach(this.items, (c: Conversation) => {
            ListItem() {
              Row() {
                Column() {
                  Text(c.title.length > 0 ? c.title : '未命名对话')
                    .fontSize(FS.body).fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                    .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  if (c.updated_at) {
                    Text(c.updated_at)
                      .fontSize(FS.caption).fontColor($r('app.color.text_tertiary'))
                      .margin({ top: 4 })
                  }
                }
                .layoutWeight(1).alignItems(HorizontalAlign.Start)
                .onClick(() => {
                  router.pushUrl({ url: 'pages/ConversationDetail', params: { 'id': c.id, 'title': c.title } });
                })

                SymbolGlyph($r('sys.symbol.arrow_clockwise')).fontSize(18)
                  .fontColor([$r('app.color.text_tertiary')]).padding(6)
                  .onClick(() => { this.regenTitle(c.id); })
                SymbolGlyph($r('sys.symbol.trash')).fontSize(18)
                  .fontColor([$r('app.color.danger')]).padding(6)
                  .onClick(() => { this.deleteConv(c.id); })
              }
              .width('100%').padding(Space.md).alignItems(VerticalAlign.Center)
              .backgroundColor($r('app.color.bg_card')).borderRadius(R.card)
              .border({ width: 1, color: $r('app.color.border_soft') })
            }
            .margin({ bottom: Space.sm })
          }, (c: Conversation) => c.id)
        }
        .layoutWeight(1).width('100%')
        .padding({ left: Space.lg, right: Space.lg, top: Space.md })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_base'))
  }
}
