import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Api } from './Api';
import { Prefs } from '../storage/Prefs';

interface VoiceMsg {
  type: string;
  data?: string;
  conversation_id?: string;
}

/// 语音通话 WebSocket 客户端（对应 Flutter VoiceBloc 的 WebSocketClient）。
/// 负责与后端 /api/consult/voice/ws 的 JSON 协议收发；音频采集/播放由 Call 页驱动。
export class VoiceClient {
  private ws: webSocket.WebSocket | null = null;

  public onConnected: (convId: string) => void = () => {};
  public onText: (t: string) => void = () => {};
  public onUserText: (t: string) => void = () => {};
  public onAiText: (t: string) => void = () => {};
  public onAudio: (b64: string) => void = () => {};
  public onDone: () => void = () => {};
  public onError: (msg: string) => void = () => {};
  public onClose: () => void = () => {};

  connect(conversationId: string = ''): void {
    const base: string = Api.baseUrl.replace('https://', 'wss://').replace('http://', 'ws://');
    let url: string = base + Api.voiceWs + '?token=' + Prefs.token;
    if (conversationId.length > 0) {
      url += '&conversation_id=' + conversationId;
    }
    this.ws = webSocket.createWebSocket();

    this.ws.on('message', (err: BusinessError, data: string | ArrayBuffer) => {
      if (typeof data !== 'string') {
        return;
      }
      try {
        const msg: VoiceMsg = JSON.parse(data) as VoiceMsg;
        if (msg.type === 'connected') {
          this.onConnected(msg.conversation_id ?? '');
        } else if (msg.type === 'text') {
          this.onText(msg.data ?? '');
        } else if (msg.type === 'audio') {
          this.onAudio(msg.data ?? '');
        } else if (msg.type === 'user_text') {
          this.onUserText(msg.data ?? '');
        } else if (msg.type === 'ai_text') {
          this.onAiText(msg.data ?? '');
        } else if (msg.type === 'done') {
          this.onDone();
        } else if (msg.type === 'error') {
          this.onError(msg.data ?? '未知错误');
        }
      } catch (e) {
        // 忽略非法消息
      }
    });
    this.ws.on('close', () => { this.onClose(); });
    this.ws.on('error', (err: BusinessError) => { this.onError('语音连接错误'); });
    this.ws.connect(url, (err: BusinessError, ok: Object) => {
      if (err) {
        this.onError('无法连接语音服务');
      }
    });
  }

  private sendJson(obj: VoiceMsg): void {
    if (this.ws !== null) {
      this.ws.send(JSON.stringify(obj));
    }
  }

  sendAudio(b64: string): void {
    this.sendJson({ type: 'audio', data: b64 });
  }

  sendImage(b64: string): void {
    this.sendJson({ type: 'image', data: b64 });
  }

  commit(): void {
    this.sendJson({ type: 'commit' });
  }

  ping(): void {
    this.sendJson({ type: 'ping' });
  }

  close(): void {
    this.sendJson({ type: 'stop' });
    if (this.ws !== null) {
      this.ws.close();
      this.ws = null;
    }
  }
}
