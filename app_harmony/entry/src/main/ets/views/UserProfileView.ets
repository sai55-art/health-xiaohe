import { ApiClient, ApiResp } from '../common/net/ApiClient';
import { Api } from '../common/net/Api';
import { MemoryItem } from '../common/models/Models';
import { R, Space, FS } from '../common/theme/Tokens';

interface ProfileInner {
  gender?: string;
  age?: number;
  height?: number;
  weight?: number;
  health_summary?: string;
  risk_tags?: string[];
}

interface ProfileResp {
  profile?: ProfileInner;
  memories?: MemoryItem[];
}

/// 画像页（对应 Flutter user_profile_page）：健康摘要 + 风险标签 + 长期记忆。
@Component
export struct UserProfileView {
  @State summary: string = '';
  @State tags: string[] = [];
  @State memories: MemoryItem[] = [];
  @State loading: boolean = true;
  @State err: string = '';

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    this.loading = true;
    this.err = '';
    try {
      const resp: ApiResp = await ApiClient.get(Api.userProfile, true);
      if (resp.code === 200) {
        const d: ProfileResp = JSON.parse(resp.body) as ProfileResp;
        this.summary = d.profile?.health_summary ?? '';
        this.tags = d.profile?.risk_tags ?? [];
        this.memories = d.memories ?? [];
      } else {
        this.err = '加载失败（' + resp.code + '）';
      }
    } catch (e) {
      this.err = '网络错误，请检查后端连接';
    } finally {
      this.loading = false;
    }
  }

  build() {
    Scroll() {
      Column() {
        Text('AI 印象')
          .fontSize(FS.display).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).width('100%')
        Text('健康小云对你的认识')
          .fontSize(FS.body).fontColor($r('app.color.text_secondary'))
          .width('100%').margin({ top: 4, bottom: Space.lg })

        if (this.loading) {
          LoadingProgress().width(40).height(40).color($r('app.color.primary')).margin({ top: Space.xl })
        } else if (this.err.length > 0) {
          Text(this.err).fontSize(FS.body).fontColor($r('app.color.text_muted')).margin({ top: Space.xl })
        } else {
          // 健康摘要卡
          Column() {
            Text('健康摘要').fontSize(FS.title).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
            Text(this.summary.length > 0 ? this.summary : '暂无摘要，多和我聊聊吧～')
              .fontSize(FS.body).fontColor($r('app.color.text_secondary')).margin({ top: Space.sm })
          }
          .width('100%').alignItems(HorizontalAlign.Start).padding(Space.md)
          .backgroundColor($r('app.color.bg_card')).borderRadius(R.card)
          .border({ width: 1, color: $r('app.color.border_soft') })

          // 风险标签
          if (this.tags.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (t: string) => {
                Text(t)
                  .fontSize(FS.caption).fontColor($r('app.color.primary_dark'))
                  .backgroundColor($r('app.color.primary_light')).borderRadius(R.chip)
                  .padding({ left: Space.md, right: Space.md, top: 6, bottom: 6 })
                  .margin({ right: Space.sm, bottom: Space.sm })
              }, (t: string) => t)
            }
            .width('100%').margin({ top: Space.md })
          }

          // 长期记忆
          Text('长期记忆')
            .fontSize(FS.title).fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .width('100%').margin({ top: Space.lg, bottom: Space.sm })
          ForEach(this.memories, (m: MemoryItem) => {
            Column() {
              Text(m.category).fontSize(FS.caption).fontColor($r('app.color.accent'))
              Text(m.fact).fontSize(FS.body).fontColor($r('app.color.text_primary')).margin({ top: 4 })
            }
            .width('100%').alignItems(HorizontalAlign.Start).padding(Space.md)
            .backgroundColor($r('app.color.bg_card')).borderRadius(R.card)
            .border({ width: 1, color: $r('app.color.border_soft') })
            .margin({ bottom: Space.sm })
          }, (m: MemoryItem) => m.id)

          if (this.memories.length === 0) {
            Text('还没有记忆条目').fontSize(FS.caption).fontColor($r('app.color.text_muted')).margin({ top: Space.sm })
          }
        }
      }
      .width('100%').padding(Space.lg).alignItems(HorizontalAlign.Start)
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_base'))
    .align(Alignment.Top)
  }
}
