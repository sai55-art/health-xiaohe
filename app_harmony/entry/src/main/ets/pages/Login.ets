// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import { router, promptAction } from '@kit.ArkUI';
import { ApiClient, ApiResp } from '../common/net/ApiClient';
import { Api } from '../common/net/Api';
import { Prefs } from '../common/storage/Prefs';
import { LoginResp } from '../common/models/Models';
import { R, Space, FS } from '../common/theme/Tokens';

/// 登录/注册页（对应 Flutter login_page，奶油暖调 + 宋体大字品牌名）。
@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State isLogin: boolean = true;
  @State loading: boolean = false;
  @State entered: boolean = false;

  aboutToAppear(): void {
    // 进场：淡入 + 轻微上浮（对应 Flutter Entrance）。先渲染初始态再 animateTo
    setTimeout(() => {
      animateTo({ duration: 420, curve: Curve.EaseOut }, () => {
        this.entered = true;
      });
    }, 16);
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 2000 });
  }

  private async onSubmit(): Promise<void> {
    if (this.phone.length === 0 || this.password.length === 0) {
      this.toast('请填写完整信息');
      return;
    }
    if (this.password.length < 6) {
      this.toast('密码至少 6 位');
      return;
    }
    this.loading = true;
    try {
      const payload: Record<string, string> = { 'phone': this.phone, 'password': this.password };
      const resp: ApiResp = await ApiClient.post(
        this.isLogin ? Api.login : Api.register, payload, false);
      if (resp.code === 200 || resp.code === 201) {
        if (this.isLogin) {
          const data: LoginResp = JSON.parse(resp.body) as LoginResp;
          const token: string = data.access_token ?? data.token ?? '';
          Prefs.putString(Prefs.KEY_TOKEN, token);
          if (data.user) {
            Prefs.putString(Prefs.KEY_NICKNAME, data.user.nickname);
            Prefs.putString(Prefs.KEY_PHONE, data.user.phone);
            Prefs.putString(Prefs.KEY_USER_ID, data.user.id);
          }
          router.replaceUrl({ url: 'pages/Main' });
        } else {
          this.isLogin = true;
          this.toast('注册成功，请登录');
        }
      } else {
        this.toast('操作失败（' + resp.code + '）');
      }
    } catch (e) {
      this.toast('网络错误，请检查后端连接');
    } finally {
      this.loading = false;
    }
  }

  @Builder
  inputField(placeholder: string, isPassword: boolean, onChange: (v: string) => void) {
    TextInput({ placeholder: placeholder })
      .type(isPassword ? InputType.Password : InputType.Normal)
      .placeholderColor($r('app.color.text_muted'))
      .fontColor($r('app.color.text_primary'))
      .backgroundColor($r('app.color.bg_card'))
      .height(56)
      .borderRadius(R.input)
      .border({ width: 1, color: $r('app.color.border') })
      .padding({ left: Space.lg, right: Space.lg })
      .margin({ bottom: Space.md })
      .onChange(onChange)
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 品牌锚点小方块
          Column() {
            Text('🌿').fontSize(26)
          }
          .width(52)
          .height(52)
          .borderRadius(R.logo)
          .backgroundColor($r('app.color.primary'))
          .justifyContent(FlexAlign.Center)
          .margin({ top: 72, bottom: Space.lg })

          Text('HEALTH XIAOHE')
            .fontSize(FS.overline)
            .letterSpacing(2)
            .fontColor($r('app.color.text_tertiary'))
            .width('100%')
            .textAlign(TextAlign.Start)

          Text('健康小云')
            .fontSize(34)
            .fontFamily('NotoSerifSC')
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 6 })

          Text('你的 AI 健康管家')
            .fontSize(FS.body)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 6, bottom: Space.xl })

          this.inputField('请输入手机号', false, (v: string) => { this.phone = v; })
          this.inputField('请输入密码', true, (v: string) => { this.password = v; })

          Button(this.loading ? '处理中…' : (this.isLogin ? '登录' : '注册'))
            .width('100%')
            .height(56)
            .fontSize(17)
            .fontColor($r('app.color.on_primary'))
            .backgroundColor($r('app.color.primary'))
            .borderRadius(R.input)
            .enabled(!this.loading)
            .margin({ top: Space.sm })
            .onClick(() => { this.onSubmit(); })

          Text('登录即表示同意《用户协议》和《隐私政策》')
            .fontSize(FS.caption)
            .fontColor($r('app.color.text_muted'))
            .margin({ top: Space.lg })

          Button(this.isLogin ? '还没有账号？立即注册' : '已有账号？登录')
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.primary_dark'))
            .fontSize(FS.caption)
            .margin({ top: Space.xs })
            .onClick(() => { this.isLogin = !this.isLogin; })
        }
        .width('100%')
        .padding({ left: Space.lg, right: Space.lg })
        .alignItems(HorizontalAlign.Start)
        .opacity(this.entered ? 1 : 0)
        .translate({ y: this.entered ? 0 : 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_base'))
  }
}
