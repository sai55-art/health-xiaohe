/// 后端端点常量。baseUrl 与 Flutter 端一致，对接同一 :8002 后端。
/// 鸿蒙模拟器/真机需与后端同局域网；换网络时改此处 IP。
export class Api {
  // 鸿蒙模拟器访问宿主机后端走 10.0.2.2（QEMU NAT 映射宿主 localhost）。
  // 真机联调改为电脑局域网 IP，如 http://192.168.1.84:8002，并确保同一 WiFi。
  static readonly baseUrl: string = 'http://10.0.2.2:8002';

  // Auth
  static readonly login: string = '/api/auth/login';
  static readonly register: string = '/api/auth/register';
  static readonly me: string = '/api/auth/me';

  // Chat
  static readonly chat: string = '/api/consult/chat';
  static readonly chatStream: string = '/api/consult/chat/stream';
  static readonly conversations: string = '/api/consult/conversations';

  static conversationDetail(id: string): string {
    return '/api/consult/conversations/' + id;
  }

  // User profile & memory
  static readonly userProfile: string = '/api/user/profile';
}
