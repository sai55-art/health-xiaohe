import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/// 轻量持久化封装（对应 Flutter 端 LocalStorage，基于 @ohos.data.preferences）。
const STORE_NAME: string = 'health_xiaohe';

export class Prefs {
  private static store: preferences.Preferences | null = null;

  static init(context: common.UIAbilityContext): void {
    Prefs.store = preferences.getPreferencesSync(context, { name: STORE_NAME });
  }

  static getString(key: string, def: string = ''): string {
    if (Prefs.store === null) {
      return def;
    }
    return Prefs.store.getSync(key, def) as string;
  }

  static putString(key: string, value: string): void {
    if (Prefs.store === null) {
      return;
    }
    Prefs.store.putSync(key, value);
    Prefs.store.flush();
  }

  static getBool(key: string, def: boolean = false): boolean {
    if (Prefs.store === null) {
      return def;
    }
    return Prefs.store.getSync(key, def) as boolean;
  }

  static putBool(key: string, value: boolean): void {
    if (Prefs.store === null) {
      return;
    }
    Prefs.store.putSync(key, value);
    Prefs.store.flush();
  }

  static remove(key: string): void {
    if (Prefs.store === null) {
      return;
    }
    Prefs.store.deleteSync(key);
    Prefs.store.flush();
  }

  // 业务键
  static readonly KEY_TOKEN: string = 'jwt_token';
  static readonly KEY_USER_ID: string = 'user_id';
  static readonly KEY_PHONE: string = 'user_phone';
  static readonly KEY_NICKNAME: string = 'user_nickname';
  static readonly KEY_DARK: string = 'dark_mode';

  static get token(): string {
    return Prefs.getString(Prefs.KEY_TOKEN, '');
  }

  static get isLoggedIn(): boolean {
    return Prefs.token.length > 0;
  }

  static clearAuth(): void {
    Prefs.remove(Prefs.KEY_TOKEN);
    Prefs.remove(Prefs.KEY_USER_ID);
    Prefs.remove(Prefs.KEY_PHONE);
    Prefs.remove(Prefs.KEY_NICKNAME);
  }
}
