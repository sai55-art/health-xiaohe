/// 数据模型（对应 Flutter 端 data/models）。JSON 解析后以类型断言使用。

export interface User {
  id: string;
  phone: string;
  nickname: string;
}

export interface ChatMessage {
  role: string; // 'user' | 'assistant'
  content: string;
  image?: string;    // 发送给后端的 base64（data URL）
  imageUri?: string; // 本地预览用的相册 uri
}

export interface Conversation {
  id: string;
  title: string;
  updated_at?: string;
}

export interface MemoryItem {
  id: string;
  category: string;
  fact: string;
  importance?: number;
}

export interface UserProfileData {
  gender?: string;
  age?: number;
  height?: number;
  weight?: number;
  health_summary?: string;
  risk_tags?: string[];
}

export interface LoginResp {
  access_token?: string;
  token?: string;
  user?: User;
}
