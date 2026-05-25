# 健康小云 App 视觉系统升级 — 设计文档

**日期**: 2026-05-25
**范围**: 建立"奶油暖调 · 哑光鼠尾草"设计系统,并在底部导航 + 聊天主页落地为标杆
**状态**: 待评审

---

## 1. 目标与背景

当前 Flutter App 视觉是"标准 Material 3 + 单一品牌色 `#4ECDC4` + 系统字体 + 默认底部导航 + 页面切换基本无定制过渡 + 各处零散手写动画",清新但缺少辨识度与高级感。

本次目标:建立一套**有自己特色的「高级简约」视觉语言**,并把它工程化为可复用的设计系统(tokens + 字体 + 动效封装),先在最高频的"咨询"页和底部导航上做出标杆效果,其余页面后续按同套系统增量推进。

**调性方向(已确认)**: 奶油暖调 —— 米白燕麦底 + 衬线大标题 + 暖柔投影 + 哑光主色,有温度的高级感。

---

## 2. 设计决策(已确认)

| 维度 | 决策 |
|------|------|
| 调性 | 奶油暖调(温暖、克制、杂志感) |
| 配色 | 哑光鼠尾草 —— 主色由 `#4ECDC4` 改为 sage `#7FB3A8`,燕麦底 |
| 字体 | 混合:大标题用宋体(Noto Serif SC)+ 英数/数字用 Fraunces;**正文用系统字体** |
| 动效 | 静润(淡入+上浮、缓出、无弹跳)做主体手感 + Stagger 依次入场用于列表/消息流 |
| 图标 | `lucide_icons`(统一线性极简图标) |

### 2.1 配色 Token(完整值)

```
// 主色 — 哑光鼠尾草
primary        #7FB3A8   // 主色:用户气泡、发送键、选中态
primaryDark    #6BA095   // 按压/强调
primaryLight   #E7F0EE   // 浅 sage:底部导航药丸高亮底、轻强调背景

// 背景 — 燕麦奶油
bgBase         #F6F4EE   // 页面底色
bgCard         #FFFFFF   // 卡片/气泡白底
bgSubtle       #ECE8DF   // 浅燕麦:标签 chip、分割、次级容器

// 点缀 — 暖砂
accent         #B9A88F   // 次要强调(克制使用)

// 文字 — 暖墨阶
textPrimary    #3D3A34   // 主文字
textSecondary  #736B60   // 次级
textTertiary   #A89F92   // 辅助/单位
textMuted      #B0A89B   // 占位符

// 边框
border         #ECE8DF   // 通用细边
borderSoft     #EFEAE0   // 气泡/卡片细边

// 功能色(暖调,与奶油底协调)
success        #6BAE78   // 暖绿
warning        #E0A24E   // 琥珀
danger         #D9695F   // 陶红
```

### 2.2 字体 Token

| Token | 字体 | 字重 | 字号 | 用途 |
|-------|------|------|------|------|
| `displaySerif` | Noto Serif SC | 600 | 26 | 主页问候、页面主标题 |
| `headingSerif` | Noto Serif SC | 500 | 20 | 区块标题 |
| `overline` | Fraunces | 600 | 11(字距 +2) | 英文小标签(如 HEALTH XIAOHE) |
| `titleSans` | 系统 | 500 | 16 | 列表项标题、导航标题 |
| `body` | 系统 | 400 | 14(行高 1.6) | 正文、气泡 |
| `caption` | 系统 | 400 | 12 | 辅助说明、标签文字 |
| `numeric` | Fraunces | 600 | 按场景 | 数字/数据(血压、步数、时长) |

> 中文宋体/Fraunces 打包到本地,正文/无衬线交给系统字体(Android 思源黑体、iOS 苹方)。

### 2.3 动效 Token

```
durationFast   180ms   // 按压反馈、小状态切换
durationBase   280ms   // 入场、页面过渡(默认)
durationSlow   420ms   // 大块过渡

curveCalm      Cubic(0.22, 0.61, 0.36, 1)   // 静润主曲线(强缓出、无回弹)

entranceOffset 16px(上浮距离,opacity 0→1)
staggerStep    60ms(列表逐项延迟)
pageOffset     12px(页面过渡上浮距离)
```

**禁用**:bounce / overshoot / 弹性回弹曲线(与高级简约气质冲突)。

### 2.4 阴影 Token(暖投影,非纯黑)

```
shadowSoft     color rgba(140,130,110,0.10), blur 16, offset (0,6)   // 气泡
shadowCard     color rgba(140,130,110,0.13), blur 22, offset (0,8)   // 卡片
shadowPrimary  color rgba(127,179,168,0.35), blur 12, offset (0,4)   // sage 实心按钮
```

### 2.5 圆角 Token

```
radiusChip   16   radiusBubble 18(尾角 6)   radiusCard 20
radiusInput  24   radiusLogo   13
```

间距沿用现有 `AppSpacing`(4/8/16/24/32/48,8pt 网格)。

---

## 3. 技术架构

### 3.1 文件组织(`health_xiaohe/lib/core/`)

| 文件 | 类型 | 职责 | 依赖 |
|------|------|------|------|
| `theme/app_colors.dart` | 改写 | 新 sage 色板;**保留旧常量名并重映射到新值** | — |
| `theme/app_typography.dart` | 新增 | 暴露 §2.2 的 `TextStyle` getter | app_colors |
| `theme/app_motion.dart` | 新增 | 暴露 §2.3 的 Duration / Curve / 常量 | — |
| `theme/app_shadows.dart` | 新增 | 暴露 §2.4 的 `List<BoxShadow>` | app_colors |
| `theme/app_radius.dart` | 新增 | §2.5 圆角常量 | — |
| `theme/app_theme.dart` | 改写 | 用以上 token 配置 M3 `ThemeData` | 全部 token |
| `animations/entrance.dart` | 新增 | 可复用入场动画 widget(见 §5.1) | app_motion |
| `animations/page_transitions.dart` | 新增 | go_router 自定义过渡(见 §5.2) | app_motion |

**单一职责**:每个 token 文件只暴露一类常量;`app_theme` 是唯一组装点;动效封装与 token 解耦(只读 motion token)。

### 3.2 兼容策略(降低爆改风险)

`app_colors.dart` 中**保留所有旧常量名**(`primary` `primaryLight` `aiBubbleBg` `textPrimary` …),但其值重新映射到新色板。效果:

- 本期未改造的页面(画像/历史/我的/登录/通话)**不会编译失败**,只是自动呈现新配色。
- 标杆页面(聊天主页)用新增 token 精细控制。

旧色板与新色板的映射在 `app_colors.dart` 顶部以注释表说明,便于后续逐页清理。

---

## 4. 字体打包

1. 获取字体源文件:
   - Noto Serif SC(字重 500、600)— 思源宋体,Google Fonts / Noto 仓库
   - Fraunces(字重 600;含拉丁字符与数字)
2. **子集化**(控制体积):用 `fonttools pyftsubset` 对 Noto Serif SC 按常用汉字字表(GB2312 一级字库 + 常用标点,约 3500 字)裁剪;Fraunces 仅保留拉丁 + 数字 + 常用标点。
3. 放入 `health_xiaohe/assets/fonts/`,在 `pubspec.yaml` 的 `flutter.fonts` 声明 family:`NotoSerifSC`、`Fraunces`。
4. 正文不打包(用系统字体)。
5. 预期总增量 **1~2MB**。

> 验证点:打包后中文标题(含生僻字回退到系统宋体不崩)、英数 Fraunces 正常显示;APK 体积增量在预期内。

---

## 5. 动效与页面过渡(可复用件)

### 5.1 `Entrance` widget

- **做什么**:子组件首次挂载时,执行"淡入 + 上浮 16px"入场(curveCalm,durationBase)。
- **怎么用**:`Entrance(index: i, child: ...)`。`index` 用于 stagger —— 实际延迟 = `min(index, 5) * staggerStep`(**最大延迟封顶 300ms**,避免长列表越往后越慢)。
- **依赖**:`app_motion`。内部用 `StatefulWidget` + `AnimationController`(单次 forward,不 repeat)。
- 不破坏现有列表性能:与 `RepaintBoundary` / 气泡缓存兼容(入场只在首次构建跑一次)。

**stagger 的适用边界(避免历史对话整列飞入)**:

- **首屏少量元素**(问候区、追问标签):用 `index` 做 stagger,逐个入场。
- **历史对话批量加载**:整列**不逐条 stagger** —— 一次性加载的历史消息直接显示(或整体一次轻淡入),不依次飞入,否则加载长对话会很慢很怪。
- **新到达的单条消息**(用户发送 / AI 新回复):该条用 `Entrance` 单独入场(`index: 0`)。

实现上以"是否新增消息"区分:历史加载走普通路径,新增消息才包 `Entrance`。

### 5.2 页面过渡

- **做什么**:替换 go_router 默认平台过渡为统一的"淡入 + 上浮 12px"(curveCalm,durationBase)。
- **怎么用**:`page_transitions.dart` 暴露一个 `fadeUpPage({child})` 返回 `CustomTransitionPage`;`app_router.dart` 的各 `GoRoute` 用 `pageBuilder` 替代 `builder`。
- **Tab 切换**(ShellRoute 内):`MainShell` 的 `child` 外层套 `AnimatedSwitcher`(durationFast 淡入),让 4 个 tab 间切换有柔和过渡而非瞬切。

---

## 6. 组件改动(本期标杆范围)

### 6.1 自定义底部导航(替换默认 `BottomNavigationBar`)

- 新增 widget(在 `app_router.dart` 的 `MainShell` 内,或抽到 `presentation/widgets/common/`)。
- 样式:`bgCard` 白底 + 顶部 1px `#F0EBE1` 细边,**无 Material 重投影**。
- 4 项(咨询/画像/历史/我的):当前项 = 浅 sage 药丸底(`primaryLight`)+ sage 填充图标 + sage label;非当前 = 暖灰线性图标 + `textTertiary` label。
- 图标用 `lucide_icons`(线性);选中/未选中用同一图标的视觉强调差异(颜色 + 药丸底),不切换填充/描边两套。
- 切换时图标/label 颜色过渡 durationFast。

### 6.2 ChatHomePage 改造

- **顶栏**:logo 改 `radiusLogo` 圆角 + sage 渐变;标题 `titleSans`;新建对话按钮换 lucide 图标。
- **问候区**(替换原渐变 welcome 大卡):
  - `overline` 小标签 "HEALTH XIAOHE"
  - `displaySerif` 宋体问候(按时段:早安/午安/晚上好 + "我是小云")
  - `caption` 副文一句
  - quick tips 标签下移,用 `bgSubtle` 燕麦底 chip
- **消息流**:气泡套新 token(见 6.3);每条消息用 `Entrance` 依次入场(stagger)。
- **追问建议 chip**:`bgSubtle` 底、去描边、`caption` 文字、sage 文字色。
- **输入栏**(`ChatInputField`):白底 `radiusInput` 药丸 + `shadowSoft`;语音键圆形浅底;发送键 sage 实心圆 + `shadowPrimary`;图标换 lucide。
- **加载态**:`thinking` 指示沿用,色彩换 sage。

### 6.3 MessageBubble 改造

- AI 气泡:`bgCard` 白底 + 1px `borderSoft` + `shadowSoft`,圆角 `radiusBubble`(左下尾角 6)。
- 用户气泡:`primary` sage 底 + 白字 + `shadowPrimary`,圆角 `radiusBubble`(右下尾角 6)。
- 气泡内数字(若结构化呈现)可用 `numeric`(Fraunces);Markdown 正文用 `body`。
- 保留现有流式光标 / Markdown 渲染逻辑,仅换样式 token。

---

## 7. 落地顺序(增量,每步可编译可验证)

1. **地基**:Tokens(colors 改写 + typography/motion/shadows/radius 新增)+ 字体打包 + `app_theme` 改写。完成后旧页面自动换色、可正常编译运行。
2. **动效封装**:`Entrance` + `page_transitions`,接入 `app_router`(页面过渡 + tab AnimatedSwitcher)。
3. **底部导航**:自定义 widget 替换默认,接入 lucide。
4. **聊天主页**:ChatHomePage + MessageBubble + ChatInputField 套用 token 与 `Entrance`。

每步独立提交,便于真机验证与回退。

---

## 8. 范围边界

**本期 in**:设计系统全部 token + 字体 + 动效封装 + 页面过渡 + 底部导航 + 聊天主页(含气泡/输入栏)。

**本期 out(后续增量)**:画像页、历史页、个人中心、登录页、通话页的逐页套用;深色模式;插画/吉祥物重绘。这些后续各自按本套系统推进,不在本 spec。

---

## 9. 验证方式

- **编译**:`flutter analyze` 无新增 error;`flutter run` 真机启动正常。
- **视觉**:聊天主页实机效果对齐标杆稿(燕麦底、宋体问候、哑光 sage 气泡、克制留白)。
- **动效**:进页面消息/标签依次淡入上浮(无弹跳);tab 切换与页面跳转为柔和淡入上浮,主观流畅不卡顿(延续上一轮已修复的主线程优化)。
- **字体**:中文宋体标题、Fraunces 数字正确显示;APK 体积增量 1~2MB 区间。
- **兼容**:未改造页面正常编译、自动呈现新配色、无错位。
