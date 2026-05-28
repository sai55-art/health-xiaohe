import { http } from '@kit.NetworkKit';
import { Api } from './Api';
import { Prefs } from '../storage/Prefs';

export interface ApiResp {
  code: number;
  body: string;
}

/// 基于 @ohos.net.http 的 REST 封装（对应 Flutter 端 dio ApiClient）。
/// 自动带 JWT。流式聊天另见 ChatApi.streamChat。
export class ApiClient {
  private static buildHeader(auth: boolean): Record<string, string> {
    const h: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    if (auth) {
      const token: string = Prefs.token;
      if (token.length > 0) {
        h['Authorization'] = 'Bearer ' + token;
      }
    }
    return h;
  }

  static async request(method: http.RequestMethod, path: string,
    body: object | null, auth: boolean): Promise<ApiResp> {
    const req = http.createHttp();
    try {
      const options: http.HttpRequestOptions = {
        method: method,
        header: ApiClient.buildHeader(auth),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 15000,
        readTimeout: 60000
      };
      if (body !== null) {
        options.extraData = JSON.stringify(body);
      }
      const resp = await req.request(Api.baseUrl + path, options);
      return { code: resp.responseCode as number, body: resp.result as string };
    } finally {
      req.destroy();
    }
  }

  static post(path: string, body: object, auth: boolean = true): Promise<ApiResp> {
    return ApiClient.request(http.RequestMethod.POST, path, body, auth);
  }

  static get(path: string, auth: boolean = true): Promise<ApiResp> {
    return ApiClient.request(http.RequestMethod.GET, path, null, auth);
  }

  static del(path: string, auth: boolean = true): Promise<ApiResp> {
    return ApiClient.request(http.RequestMethod.DELETE, path, null, auth);
  }
}
