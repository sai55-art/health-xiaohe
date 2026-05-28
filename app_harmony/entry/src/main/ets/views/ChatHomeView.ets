import { http } from '@kit.NetworkKit';
import { router } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { MarkdownText } from '../components/MarkdownText';
import { Api } from '../common/net/Api';
import { Prefs } from '../common/storage/Prefs';
import { ChatMessage } from '../common/models/Models';
import { R, Space, FS } from '../common/theme/Tokens';

interface ChatReqBody {
  messages: ChatMessage[];
  stream: boolean;
  conversation_id?: string;
}

interface StreamChunk {
  content?: string;
  conversation_id?: string;
  suggestions?: string[];
}

/// 聊天首页（对应 Flutter chat_home_page）：宋体问候 + 气泡 + 输入栏。
/// 流式对接 /api/consult/chat/stream（SSE）。
///
/// 解析策略：累积全部响应字节，每次 dataReceive 都对「迄今所有字节」整体
/// 解码并重新解析所有 SSE 事件。这样已 \n\n 结尾的事件字节必然完整，
/// 避免中文（3 字节 UTF-8）被 TCP 分块切断导致 JSON 解析失败、丢失片段。
@Component
export struct ChatHomeView {
  @State messages: ChatMessage[] = [];
  @State input: string = '';
  @State sending: boolean = false;
  @State conversationId: string = '';
  @State suggestions: string[] = [];
  @State entered: boolean = false;
  @State selectedUri: string = '';
  private selectedB64: string = '';
  private scroller: Scroller = new Scroller();
  private streamBytes: number[] = [];
  private streamAcc: string = '';
  private quickTips: string[] = ['最近总失眠怎么办', '如何健康减重', '祛湿调理建议', '改善焦虑情绪'];

  aboutToAppear(): void {
    setTimeout(() => {
      animateTo({ duration: 420, curve: Curve.EaseOut }, () => {
        this.entered = true;
      });
    }, 16);
  }

  // 相册选图 → 读取 → base64（无需权限，系统安全选择器）
  private async pickImage(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const opt = new photoAccessHelper.PhotoSelectOptions();
      opt.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      opt.maxSelectNumber = 1;
      const res: photoAccessHelper.PhotoSelectResult = await picker.select(opt);
      if (res.photoUris.length > 0) {
        const uri: string = res.photoUris[0];
        const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
        const stat = fileIo.statSync(file.fd);
        const buf: ArrayBuffer = new ArrayBuffer(stat.size);
        fileIo.readSync(file.fd, buf);
        fileIo.closeSync(file);
        const helper = new util.Base64Helper();
        const b64: string = helper.encodeToStringSync(new Uint8Array(buf));
        this.selectedUri = uri;
        this.selectedB64 = 'data:image/jpeg;base64,' + b64;
      }
    } catch (e) {
      // 取消选择或读取失败，忽略
    }
  }

  private greeting(): string {
    const h: number = new Date().getHours();
    if (h < 6) {
      return '夜深了，注意休息';
    } else if (h < 12) {
      return '早上好';
    } else if (h < 14) {
      return '中午好';
    } else if (h < 18) {
      return '下午好';
    }
    return '晚上好';
  }

  // 对迄今累积的全部字节整体解码并解析，重算回复全文
  private parseAll(decoder: util.TextDecoder, lastIdx: number): void {
    const full: string = decoder.decodeToString(new Uint8Array(this.streamBytes));
    const events: string[] = full.split('\n\n');
    let acc: string = '';
    let convId: string = '';
    for (let i = 0; i < events.length; i++) {
      const line: string = events[i].trim();
      if (!line.startsWith('data:')) {
        continue;
      }
      const payload: string = line.substring(5).trim();
      if (payload === '[DONE]' || payload.length === 0) {
        continue;
      }
      try {
        const obj: StreamChunk = JSON.parse(payload) as StreamChunk;
        if (obj.content !== undefined) {
          acc += obj.content;
        }
        if (obj.conversation_id !== undefined) {
          convId = obj.conversation_id;
        }
        if (obj.suggestions !== undefined && obj.suggestions.length > 0) {
          this.suggestions = obj.suggestions;
        }
      } catch (e) {
        // 末尾不完整事件，等后续字节到达再补全
      }
    }
    this.streamAcc = acc;
    if (convId.length > 0) {
      this.conversationId = convId;
    }
    this.messages.splice(lastIdx, 1, {
      role: 'assistant',
      content: acc.length > 0 ? acc : '健康小云正在思考…'
    } as ChatMessage);
    this.scroller.scrollEdge(Edge.Bottom);
  }

  private async sendStream(): Promise<void> {
    const text: string = this.input.trim();
    if (text.length === 0 || this.sending) {
      return;
    }
    const userMsg: ChatMessage = { role: 'user', content: text };
    if (this.selectedB64.length > 0) {
      userMsg.image = this.selectedB64;
      userMsg.imageUri = this.selectedUri;
    }
    this.messages.push(userMsg);
    const imgToSend: string = this.selectedB64;
    this.selectedB64 = '';
    this.selectedUri = '';
    const history: ChatMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      history.push({ role: this.messages[i].role, content: this.messages[i].content } as ChatMessage);
    }
    if (imgToSend.length > 0) {
      history[history.length - 1].image = imgToSend;
    }
    this.input = '';
    this.sending = true;
    this.messages.push({ role: 'assistant', content: '健康小云正在思考…' } as ChatMessage);
    const lastIdx: number = this.messages.length - 1;
    this.streamBytes = [];
    this.streamAcc = '';
    this.suggestions = [];

    const req = http.createHttp();
    const decoder = util.TextDecoder.create('utf-8');

    req.on('dataReceive', (data: ArrayBuffer) => {
      const arr = new Uint8Array(data);
      for (let i = 0; i < arr.length; i++) {
        this.streamBytes.push(arr[i]);
      }
      this.parseAll(decoder, lastIdx);
    });
    req.on('dataEnd', () => {
      this.parseAll(decoder, lastIdx);
      if (this.streamAcc.length === 0) {
        this.messages.splice(lastIdx, 1, { role: 'assistant', content: '（无回复）' } as ChatMessage);
      }
      this.sending = false;
      req.off('dataReceive');
      req.off('dataEnd');
      req.destroy();
    });

    const body: ChatReqBody = { messages: history, stream: true };
    if (this.conversationId.length > 0) {
      body.conversation_id = this.conversationId;
    }
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      'Authorization': 'Bearer ' + Prefs.token
    };

    try {
      const code: number = await req.requestInStream(Api.baseUrl + Api.chatStream, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(body),
        connectTimeout: 15000,
        readTimeout: 60000
      });
      if (code !== 200 && this.streamAcc.length === 0) {
        this.messages.splice(lastIdx, 1, { role: 'assistant', content: '失败(' + code + ')' } as ChatMessage);
        this.sending = false;
        req.destroy();
      }
    } catch (e) {
      this.messages.splice(lastIdx, 1, { role: 'assistant', content: '网络错误，请检查后端连接' } as ChatMessage);
      this.sending = false;
      req.destroy();
    }
  }

  // 快捷问题 / 跟问建议 chip 行（点击即填入输入框并发送）
  @Builder
  chipRow(items: string[]) {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(items, (t: string) => {
        Text(t)
          .fontSize(FS.caption).fontColor($r('app.color.primary_dark'))
          .backgroundColor($r('app.color.bg_subtle')).borderRadius(R.chip)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .margin({ right: Space.sm, bottom: Space.sm })
          .onClick(() => {
            this.input = t;
            this.sendStream();
          })
      }, (t: string) => t)
    }
    .padding({ left: Space.md, right: Space.md, top: Space.sm })
  }

  @Builder
  bubble(msg: ChatMessage) {
    Row() {
      if (msg.role === 'user') {
        Column() {
          if (msg.imageUri !== undefined && msg.imageUri.length > 0) {
            Image(msg.imageUri)
              .width(150).borderRadius(10).objectFit(ImageFit.Cover)
              .margin({ bottom: msg.content.length > 0 ? 6 : 0 })
          }
          if (msg.content.length > 0) {
            Text(msg.content)
              .fontSize(FS.body)
              .fontColor($r('app.color.on_primary'))
          }
        }
        .backgroundColor($r('app.color.primary'))
        .borderRadius(R.bubble)
        .padding(Space.md)
        .constraintSize({ maxWidth: '80%' })
        .alignItems(HorizontalAlign.End)
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
      Column() {
        Text('HEALTH XIAOHE')
          .fontSize(FS.overline).letterSpacing(2)
          .fontColor($r('app.color.text_tertiary')).width('100%')
        Text(this.greeting())
          .fontSize(FS.display).fontFamily('NotoSerifSC').fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).width('100%').margin({ top: 6 })
        Text('今天有什么健康问题想问我？')
          .fontSize(FS.body).fontColor($r('app.color.text_secondary'))
          .width('100%').margin({ top: 4 })
      }
      .padding(Space.lg)
      .alignItems(HorizontalAlign.Start)
      .opacity(this.entered ? 1 : 0)
      .translate({ y: this.entered ? 0 : 16 })

      if (this.messages.length === 0) {
        this.chipRow(this.quickTips)
      }

      List({ scroller: this.scroller }) {
        ForEach(this.messages, (msg: ChatMessage) => {
          ListItem() {
            this.bubble(msg)
          }
        }, (msg: ChatMessage, idx: number) => idx.toString() + msg.content)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: Space.md, right: Space.md })
      .scrollBar(BarState.Off)

      if (this.suggestions.length > 0 && !this.sending) {
        this.chipRow(this.suggestions)
      }

      if (this.selectedUri.length > 0) {
        Row() {
          Image(this.selectedUri)
            .width(56).height(56).borderRadius(8).objectFit(ImageFit.Cover)
          Text('✕')
            .fontSize(16).fontColor($r('app.color.text_secondary')).padding(8)
            .onClick(() => {
              this.selectedUri = '';
              this.selectedB64 = '';
            })
        }
        .padding({ left: Space.md, top: Space.sm })
        .width('100%')
      }

      Row() {
        SymbolGlyph($r('sys.symbol.camera'))
          .fontSize(24).fontColor([$r('app.color.text_secondary')]).padding(8)
          .onClick(() => { this.pickImage(); })
        SymbolGlyph($r('sys.symbol.phone'))
          .fontSize(24).fontColor([$r('app.color.primary')]).padding(8)
          .onClick(() => {
            const p: Record<string, string> = { 'conversationId': this.conversationId };
            router.pushUrl({ url: 'pages/Call', params: p });
          })
        TextInput({ text: this.input, placeholder: '请输入您的健康问题…' })
          .layoutWeight(1)
          .height(48)
          .backgroundColor($r('app.color.bg_base'))
          .borderRadius(R.input)
          .border({ width: 1, color: $r('app.color.border') })
          .padding({ left: Space.md, right: Space.md })
          .fontColor($r('app.color.text_primary'))
          .placeholderColor($r('app.color.text_muted'))
          .onChange((v: string) => { this.input = v; })
        Button('发送')
          .height(48)
          .backgroundColor($r('app.color.primary'))
          .fontColor($r('app.color.on_primary'))
          .borderRadius(R.input)
          .margin({ left: Space.sm })
          .enabled(!this.sending)
          .onClick(() => { this.sendStream(); })
      }
      .padding(Space.md)
      .backgroundColor($r('app.color.bg_card'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_base'))
  }
}
