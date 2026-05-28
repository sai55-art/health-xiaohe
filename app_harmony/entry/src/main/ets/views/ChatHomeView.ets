import { http } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
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
  private scroller: Scroller = new Scroller();
  private streamBytes: number[] = [];
  private streamAcc: string = '';

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
    this.messages.push({ role: 'user', content: text } as ChatMessage);
    const history: ChatMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      history.push({ role: this.messages[i].role, content: this.messages[i].content } as ChatMessage);
    }
    this.input = '';
    this.sending = true;
    this.messages.push({ role: 'assistant', content: '健康小云正在思考…' } as ChatMessage);
    const lastIdx: number = this.messages.length - 1;
    this.streamBytes = [];
    this.streamAcc = '';

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

  @Builder
  bubble(msg: ChatMessage) {
    Row() {
      Text(msg.content)
        .fontSize(FS.body)
        .fontColor(msg.role === 'user' ? $r('app.color.on_primary') : $r('app.color.text_primary'))
        .backgroundColor(msg.role === 'user' ? $r('app.color.primary') : $r('app.color.bg_card'))
        .borderRadius(R.bubble)
        .padding(Space.md)
        .constraintSize({ maxWidth: '80%' })
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
          .fontSize(FS.display).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).width('100%').margin({ top: 6 })
        Text('今天有什么健康问题想问我？')
          .fontSize(FS.body).fontColor($r('app.color.text_secondary'))
          .width('100%').margin({ top: 4 })
      }
      .padding(Space.lg)
      .alignItems(HorizontalAlign.Start)

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

      Row() {
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
