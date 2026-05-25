# 奶油暖调视觉系统升级 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把"奶油暖调 · 哑光鼠尾草"设计系统工程化为可复用 tokens + 字体 + 动效封装,并在底部导航与聊天主页落地为视觉标杆。

**Architecture:** 先建地基(token 文件 + 字体 + 主题,旧色名重映射保证未改页面不崩),再做可复用动效件(Entrance + 页面过渡),最后改造底部导航与聊天主页。每个任务自包含、可单独编译运行。

**Tech Stack:** Flutter, Material 3, go_router, flutter_bloc, lucide_icons, flutter_markdown。

**测试策略:** 这是视觉/主题改动为主的工作,不适合纯 TDD。**有明确逻辑的单元写 widget test**(色板兼容映射、Entrance 动画初末态);**纯主题/视觉改动以 `flutter analyze` 编译通过 + 真机视觉验证为准**——不为"好不好看"编造断言。所有命令在 `health_xiaohe/` 目录下执行。

参考设计文档:`docs/superpowers/specs/2026-05-25-app-visual-redesign-design.md`。

---

## 文件结构

| 文件 | 动作 | 职责 |
|------|------|------|
| `health_xiaohe/pubspec.yaml` | 改 | 加 `lucide_icons` 依赖、声明字体 family |
| `health_xiaohe/assets/fonts/` | 建 | 存放 NotoSerifSC / Fraunces 字体文件 |
| `lib/core/constants/app_colors.dart` | 改写 | 新 sage 色板 + 旧名重映射 |
| `lib/core/constants/app_typography.dart` | 建 | TextStyle token |
| `lib/core/constants/app_motion.dart` | 建 | Duration / Curve / 动效常量 |
| `lib/core/constants/app_shadows.dart` | 建 | 暖投影 BoxShadow |
| `lib/core/constants/app_radius.dart` | 建 | 圆角常量 |
| `lib/core/theme/app_theme.dart` | 改写 | 用 token 配置 ThemeData |
| `lib/core/animations/entrance.dart` | 建 | 可复用入场动画 widget |
| `lib/core/animations/page_transitions.dart` | 建 | go_router 自定义过渡 |
| `lib/presentation/widgets/common/app_bottom_nav.dart` | 建 | 自定义底部导航 |
| `lib/presentation/router/app_router.dart` | 改 | 接入过渡 + 自定义导航 + AnimatedSwitcher |
| `lib/presentation/widgets/chat/message_bubble.dart` | 改 | 套 token + 入场曲线统一 |
| `lib/presentation/widgets/chat/chat_input_field.dart` | 改 | 套 token + lucide 图标 |
| `lib/presentation/pages/chat/chat_home_page.dart` | 改 | 顶栏/问候区/chip/Entrance |
| `test/core/colors_test.dart` | 建 | 色板兼容映射测试 |
| `test/core/animations/entrance_test.dart` | 建 | Entrance 动画测试 |

> 路径前缀:除 pubspec/assets 外,均在 `health_xiaohe/` 下。

---

## Task 1: 依赖与字体资源

**Files:**
- Modify: `health_xiaohe/pubspec.yaml`
- Create: `health_xiaohe/assets/fonts/` (字体文件)

- [ ] **Step 1: 加 lucide_icons 依赖**

在 `pubspec.yaml` 的 `dependencies:` 下、`image: ^4.0.0` 之后加:

```yaml
  # 线性图标库(底部导航等)
  lucide_icons: ^0.257.0
```

> 若该版本号 `pub get` 解析失败,改用 `flutter pub add lucide_icons` 让 pub 选当前兼容版本,再手动确认 `pubspec.yaml` 里的版本行。

- [ ] **Step 2: 获取并子集化字体**

下载字体源文件(任一来源):
- Noto Serif SC:https://fonts.google.com/noto/specimen/Noto+Serif+SC → 取 `NotoSerifSC-Medium.ttf`(500)、`NotoSerifSC-SemiBold.ttf`(600)
- Fraunces:https://fonts.google.com/specimen/Fraunces → 取 SemiBold(600)静态实例,另存为 `Fraunces-SemiBold.ttf`

子集化中文宋体(需 `pip install fonttools`),裁到基本汉字区 + 常用标点以控制体积:

```bash
pyftsubset NotoSerifSC-Medium.ttf \
  --output-file=health_xiaohe/assets/fonts/NotoSerifSC-Medium.ttf \
  --unicodes=U+4E00-9FFF,U+3000-303F,U+FF00-FFEF,U+0020-007E
pyftsubset NotoSerifSC-SemiBold.ttf \
  --output-file=health_xiaohe/assets/fonts/NotoSerifSC-SemiBold.ttf \
  --unicodes=U+4E00-9FFF,U+3000-303F,U+FF00-FFEF,U+0020-007E
```

Fraunces 只含拉丁,直接放(可选裁拉丁+数字):

```bash
cp Fraunces-SemiBold.ttf health_xiaohe/assets/fonts/Fraunces-SemiBold.ttf
```

> 若环境暂时拿不到字体文件:仍完成 Step 3 的声明。Flutter 找不到字体文件时会回退系统字体(宋体标题在 Android 回退到系统 serif),不会崩溃,不阻塞后续任务;字体可后补。预期子集后总体积 1~3MB。

- [ ] **Step 3: 声明字体 family**

在 `pubspec.yaml` 的 `flutter:` 块内(`uses-material-design: true` 附近)加:

```yaml
  fonts:
    - family: NotoSerifSC
      fonts:
        - asset: assets/fonts/NotoSerifSC-Medium.ttf
          weight: 500
        - asset: assets/fonts/NotoSerifSC-SemiBold.ttf
          weight: 600
    - family: Fraunces
      fonts:
        - asset: assets/fonts/Fraunces-SemiBold.ttf
          weight: 600
```

并确保 assets 目录被包含(若已有 `assets:` 段则加入 `assets/fonts/`):

```yaml
  assets:
    - assets/fonts/
```

- [ ] **Step 4: 拉取依赖**

Run: `flutter pub get`
Expected: 成功,新增 `lucide_icons`。

- [ ] **Step 5: Commit**

```bash
git add health_xiaohe/pubspec.yaml health_xiaohe/pubspec.lock health_xiaohe/assets/fonts/
git commit -m "build(theme): 引入 lucide_icons 与宋体/Fraunces 字体资源"
```

---

## Task 2: 色板改写 + 兼容映射

**Files:**
- Modify: `health_xiaohe/lib/core/constants/app_colors.dart` (整文件替换)
- Test: `health_xiaohe/test/core/colors_test.dart`

- [ ] **Step 1: 写兼容映射测试**

Create `health_xiaohe/test/core/colors_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';

void main() {
  test('新语义色值正确', () {
    expect(AppColors.primary, const Color(0xFF7FB3A8));
    expect(AppColors.bgBase, const Color(0xFFF6F4EE));
    expect(AppColors.bgSubtle, const Color(0xFFECE8DF));
    expect(AppColors.accent, const Color(0xFFB9A88F));
    expect(AppColors.textPrimary, const Color(0xFF3D3A34));
  });

  test('旧常量名重映射到新色板(向后兼容,未改页面不崩)', () {
    // 旧名仍可访问,且指向新色板值
    expect(AppColors.userBubbleBg, AppColors.primary);
    expect(AppColors.aiBubbleBg, const Color(0xFFFFFFFF));
    expect(AppColors.inputBg, isNotNull);
    expect(AppColors.divider, AppColors.bgSubtle);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/core/colors_test.dart`
Expected: FAIL(`bgBase` 等未定义 / 旧值未改)。

- [ ] **Step 3: 改写 app_colors.dart**

整文件替换 `health_xiaohe/lib/core/constants/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

/// 奶油暖调 · 哑光鼠尾草 色板。
///
/// 旧常量名(primary/aiBubbleBg/textPrimary…)保留并重映射到新色板,
/// 这样本期未改造的页面不会编译失败、自动呈现新配色。后续逐页清理。
class AppColors {
  AppColors._();

  // ── 主色:哑光鼠尾草 ──
  static const Color primary = Color(0xFF7FB3A8);
  static const Color primaryDark = Color(0xFF6BA095);
  static const Color primaryLight = Color(0xFFE7F0EE); // 浅 sage:导航药丸高亮、轻强调底

  // ── 背景:燕麦奶油 ──
  static const Color bgBase = Color(0xFFF6F4EE);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSubtle = Color(0xFFECE8DF);

  // ── 点缀:暖砂 ──
  static const Color accent = Color(0xFFB9A88F);

  // ── 文字:暖墨阶 ──
  static const Color textPrimary = Color(0xFF3D3A34);
  static const Color textSecondary = Color(0xFF736B60);
  static const Color textTertiary = Color(0xFFA89F92);
  static const Color textMuted = Color(0xFFB0A89B);
  static const Color textPlaceholder = Color(0xFFB0A89B);

  // ── 边框 ──
  static const Color border = Color(0xFFECE8DF);
  static const Color borderSoft = Color(0xFFEFEAE0);

  // ── 功能色(暖调) ──
  static const Color success = Color(0xFF6BAE78);
  static const Color warning = Color(0xFFE0A24E);
  static const Color danger = Color(0xFFD9695F);

  // ── 向后兼容别名(旧名 → 新色板) ──
  static const Color secondary = primaryDark;
  static const Color backgroundStart = bgBase;
  static const Color backgroundEnd = bgCard;
  static const Color aiBubbleBg = bgCard;
  static const Color aiBubbleBorder = borderSoft;
  static const Color userBubbleBg = primary;
  static const Color userBubbleText = Color(0xFFFFFFFF);
  static const Color divider = bgSubtle;
  static const Color inputBg = bgCard;

  // 通话页深色背景(本期不改,沿用原值)
  static const Color callBgDark = Color(0xFF1A2A3A);
  static const Color callBgDarkEnd = Color(0xFF0D1520);
}
```

- [ ] **Step 4: 运行测试确认通过 + 全量 analyze**

Run: `flutter test test/core/colors_test.dart`
Expected: PASS。

Run: `flutter analyze lib/`
Expected: 无新增 error(旧页面引用的旧常量名仍解析)。

- [ ] **Step 5: Commit**

```bash
git add lib/core/constants/app_colors.dart test/core/colors_test.dart
git commit -m "feat(theme): 哑光鼠尾草色板 + 旧色名向后兼容映射"
```

---

## Task 3: Typography / Motion / Shadows / Radius token

**Files:**
- Create: `lib/core/constants/app_typography.dart`
- Create: `lib/core/constants/app_motion.dart`
- Create: `lib/core/constants/app_shadows.dart`
- Create: `lib/core/constants/app_radius.dart`

- [ ] **Step 1: 创建 app_typography.dart**

```dart
import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';

/// 字体 token:宋体大标题 + Fraunces 英数/数字 + 系统正文。
class AppTypography {
  AppTypography._();

  static const String serif = 'NotoSerifSC'; // 中文宋体(打包)
  static const String fraunces = 'Fraunces';  // 英数/数字衬线(打包)

  // 宋体大标题:主页问候、页面主标题
  static const TextStyle displaySerif = TextStyle(
    fontFamily: serif,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // 宋体区块标题
  static const TextStyle headingSerif = TextStyle(
    fontFamily: serif,
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // 英文小标签(如 HEALTH XIAOHE)
  static const TextStyle overline = TextStyle(
    fontFamily: fraunces,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 2,
    color: AppColors.textTertiary,
  );

  // 系统正文/标题
  static const TextStyle titleSans = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // 数字/数据(Fraunces);size 按场景在使用处 copyWith 覆盖
  static const TextStyle numeric = TextStyle(
    fontFamily: fraunces,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
```

- [ ] **Step 2: 创建 app_motion.dart**

```dart
import 'package:flutter/animation.dart';

/// 动效 token:静润(强缓出、无回弹)+ stagger。
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);

  /// 静润主曲线(easeOut 系,无 overshoot)。
  static const Cubic calm = Cubic(0.22, 0.61, 0.36, 1);

  static const double entranceOffset = 16; // 入场上浮距离
  static const double pageOffset = 12;      // 页面过渡上浮距离
  static const Duration staggerStep = Duration(milliseconds: 60);
  static const int staggerMaxIndex = 5;     // stagger 延迟封顶(5*60=300ms)
}
```

- [ ] **Step 3: 创建 app_shadows.dart**

```dart
import 'package:flutter/material.dart';

/// 暖投影(基于砂/墨色低透明,非纯黑)。
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x1A8C826E), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x218C826E), blurRadius: 22, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> primary = [
    BoxShadow(color: Color(0x597FB3A8), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
```

> 颜色 alpha 说明:`0x1A`≈10%、`0x21`≈13%、`0x59`≈35%。`8C826E` 是砂墨色,`7FB3A8` 是 sage。

- [ ] **Step 4: 创建 app_radius.dart**

```dart
/// 圆角 token。
class AppRadius {
  AppRadius._();

  static const double chip = 16;
  static const double bubble = 18;
  static const double bubbleTail = 6;
  static const double card = 20;
  static const double input = 24;
  static const double logo = 13;
}
```

- [ ] **Step 5: 编译验证**

Run: `flutter analyze lib/core/constants/`
Expected: No issues。

- [ ] **Step 6: Commit**

```bash
git add lib/core/constants/app_typography.dart lib/core/constants/app_motion.dart lib/core/constants/app_shadows.dart lib/core/constants/app_radius.dart
git commit -m "feat(theme): 新增 typography/motion/shadows/radius token"
```

---

## Task 4: 主题改写

**Files:**
- Modify: `health_xiaohe/lib/core/theme/app_theme.dart` (整文件替换)

- [ ] **Step 1: 改写 app_theme.dart**

整文件替换:

```dart
import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';
import 'package:health_xiaohe/core/constants/app_radius.dart';
import 'package:health_xiaohe/core/constants/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.bgCard,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.bgBase,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: AppTypography.titleSans,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          textStyle: AppTypography.titleSans.copyWith(
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textPlaceholder),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
  }
}
```

> 注:移除了 `bottomNavigationBarTheme`(本期用自定义底部导航,Task 7)。

- [ ] **Step 2: 编译 + 真机视觉验证**

Run: `flutter analyze lib/core/theme/app_theme.dart`
Expected: No issues。

Run: `flutter run`(真机)
Expected: 全局背景变燕麦色、按钮/输入框变 sage,App 正常启动无崩溃。

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "feat(theme): 主题套用奶油暖调 token"
```

---

## Task 5: Entrance 入场动画 widget

**Files:**
- Create: `lib/core/animations/entrance.dart`
- Test: `test/core/animations/entrance_test.dart`

- [ ] **Step 1: 写 widget test**

Create `health_xiaohe/test/core/animations/entrance_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_xiaohe/core/animations/entrance.dart';

void main() {
  testWidgets('Entrance 从透明渐入到不透明', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Entrance(child: Text('hi')),
    ));

    // 首帧:接近透明
    final opacityStart = tester.widget<Opacity>(
      find.ancestor(of: find.text('hi'), matching: find.byType(Opacity)).first,
    );
    expect(opacityStart.opacity, lessThan(0.2));

    // 动画结束后:完全不透明
    await tester.pumpAndSettle();
    final opacityEnd = tester.widget<Opacity>(
      find.ancestor(of: find.text('hi'), matching: find.byType(Opacity)).first,
    );
    expect(opacityEnd.opacity, 1.0);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/core/animations/entrance_test.dart`
Expected: FAIL(`entrance.dart` 不存在)。

- [ ] **Step 3: 实现 entrance.dart**

```dart
import 'package:flutter/material.dart';
import 'package:health_xiaohe/core/constants/app_motion.dart';

/// 挂载时执行"淡入 + 上浮"入场(静润曲线,单次)。
///
/// 用法:`Entrance(index: i, child: ...)`。index 用于 stagger:
/// 实际延迟 = min(index, AppMotion.staggerMaxIndex) * staggerStep。
/// 仅在首次构建跑一次,适合问候区/标签等少量首屏元素。
class Entrance extends StatefulWidget {
  final Widget child;
  final int index;

  const Entrance({super.key, required this.child, this.index = 0});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.base);
  late final Animation<double> _anim =
      CurvedAnimation(parent: _controller, curve: AppMotion.calm);

  @override
  void initState() {
    super.initState();
    final clamped =
        widget.index.clamp(0, AppMotion.staggerMaxIndex);
    final delay = AppMotion.staggerStep * clamped;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Opacity(
          opacity: _anim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _anim.value) * AppMotion.entranceOffset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
```

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/core/animations/entrance_test.dart`
Expected: PASS。

- [ ] **Step 5: Commit**

```bash
git add lib/core/animations/entrance.dart test/core/animations/entrance_test.dart
git commit -m "feat(motion): 可复用 Entrance 入场动画 widget"
```

---

## Task 6: 页面过渡 + 路由接入

**Files:**
- Create: `lib/core/animations/page_transitions.dart`
- Modify: `lib/presentation/router/app_router.dart`

- [ ] **Step 1: 创建 page_transitions.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_xiaohe/core/constants/app_motion.dart';

/// 统一页面过渡:淡入 + 轻上浮(静润曲线)。
CustomTransitionPage<void> fadeUpPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppMotion.base,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.calm);
      return FadeTransition(
        opacity: curved,
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, c) => Transform.translate(
            offset: Offset(0, (1 - curved.value) * AppMotion.pageOffset),
            child: c,
          ),
          child: child,
        ),
      );
    },
  );
}
```

- [ ] **Step 2: 路由用 pageBuilder + tab AnimatedSwitcher**

在 `app_router.dart`:

(a) 顶部加 import:

```dart
import 'package:health_xiaohe/core/animations/page_transitions.dart';
```

(b) 把**非 Shell 的** `GoRoute`(splash/login/call/chat-history detail)的 `builder:` 改为 `pageBuilder:`。例如 login:

```dart
      GoRoute(
        path: login,
        pageBuilder: (context, state) =>
            fadeUpPage(state: state, child: const LoginPage()),
      ),
```

同样改 `splash`(child `SplashPage()`)、`call`(`CallPage()`)、`/chat-history/:conversationId`(`ConversationDetailPage(conversationId: id)`)。ShellRoute 内的 4 个子路由**保持 `builder`**(tab 切换由下面的 AnimatedSwitcher 处理)。

(c) `MainShell.build` 里把 `body: child` 换成淡入切换:

```dart
      body: AnimatedSwitcher(
        duration: AppMotion.fast,
        child: KeyedSubtree(
          key: ValueKey(GoRouterState.of(context).uri.path),
          child: child,
        ),
      ),
```

并在 `app_router.dart` 顶部加 `import 'package:health_xiaohe/core/constants/app_motion.dart';`。

- [ ] **Step 3: 编译 + 真机验证**

Run: `flutter analyze lib/presentation/router/app_router.dart lib/core/animations/page_transitions.dart`
Expected: No issues。

Run: `flutter run`
Expected: 登录↔聊天等页面跳转为淡入+上浮;底部 4 tab 切换为柔和淡入(非瞬切)。

- [ ] **Step 4: Commit**

```bash
git add lib/core/animations/page_transitions.dart lib/presentation/router/app_router.dart
git commit -m "feat(motion): 统一页面过渡淡入上浮 + tab 切换淡入"
```

---

## Task 7: 自定义底部导航

**Files:**
- Create: `lib/presentation/widgets/common/app_bottom_nav.dart`
- Modify: `lib/presentation/router/app_router.dart` (MainShell 使用)

- [ ] **Step 1: 创建 app_bottom_nav.dart**

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';
import 'package:health_xiaohe/core/constants/app_motion.dart';
import 'package:health_xiaohe/core/constants/app_typography.dart';

class AppBottomNavItem {
  final IconData icon;
  final String label;
  const AppBottomNavItem(this.icon, this.label);
}

/// 奶油暖调底部导航:白底细顶边、无重投影,当前项浅 sage 药丸高亮。
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    AppBottomNavItem(LucideIcons.messageCircle, '咨询'),
    AppBottomNavItem(LucideIcons.sparkles, '画像'),
    AppBottomNavItem(LucideIcons.clock, '历史'),
    AppBottomNavItem(LucideIcons.user, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: AppMotion.fast,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w500 : FontWeight.w400,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
```

> 若 `LucideIcons.messageCircle / sparkles / clock / user` 中某个名称在所装版本不存在,用 `flutter analyze` 报错提示替换为相近名(如 `LucideIcons.messageSquare`、`LucideIcons.star`、`LucideIcons.history`、`LucideIcons.userCircle`)。

- [ ] **Step 2: MainShell 改用 AppBottomNav**

在 `app_router.dart`:

(a) 顶部加 import:

```dart
import 'package:health_xiaohe/presentation/widgets/common/app_bottom_nav.dart';
```

(b) 把 `MainShell.build` 里的 `bottomNavigationBar: BottomNavigationBar(...)` 整块替换为:

```dart
      bottomNavigationBar: AppBottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
```

`_calculateSelectedIndex` 与 `_onItemTapped` 保持不变。

- [ ] **Step 3: 编译 + 真机验证**

Run: `flutter analyze lib/presentation/widgets/common/app_bottom_nav.dart lib/presentation/router/app_router.dart`
Expected: No issues(若图标名报错按 Step 1 提示替换)。

Run: `flutter run`
Expected: 底部导航为白底细顶边、当前 tab 浅 sage 药丸 + sage 线性图标,切换有 fast 过渡。

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/common/app_bottom_nav.dart lib/presentation/router/app_router.dart
git commit -m "feat(nav): 自定义奶油暖调底部导航(lucide + sage 药丸)"
```

---

## Task 8: MessageBubble 改造

**Files:**
- Modify: `health_xiaohe/lib/presentation/widgets/chat/message_bubble.dart`

- [ ] **Step 1: 统一入场动画到 motion token**

把 `MessageBubble.build`(约 18-32 行)的 `TweenAnimationBuilder` 时长/曲线换成 token。先加 import(文件顶部):

```dart
import 'package:health_xiaohe/core/constants/app_motion.dart';
```

把:

```dart
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
```

改为:

```dart
      duration: AppMotion.base,
      curve: AppMotion.calm,
```

并把位移量 `(1 - t) * 10` 改为 `(1 - t) * AppMotion.entranceOffset`。

- [ ] **Step 2: AI 气泡套 token**

在 `AiMessageBubble.build`(约 130-141 行)的容器装饰,把:

```dart
              decoration: BoxDecoration(
                color: AppColors.aiBubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.aiBubbleBorder),
              ),
```

改为(加暖投影 + 用 radius token):

```dart
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.bubbleTail),
                  topRight: Radius.circular(AppRadius.bubble),
                  bottomLeft: Radius.circular(AppRadius.bubble),
                  bottomRight: Radius.circular(AppRadius.bubble),
                ),
                border: Border.all(color: AppColors.borderSoft),
                boxShadow: AppShadows.soft,
              ),
```

> `BorderRadius.only` 的参数需为常量,`AppRadius.*` 是 `const double`,可用。文件顶部加:
> ```dart
> import 'package:health_xiaohe/core/constants/app_radius.dart';
> import 'package:health_xiaohe/core/constants/app_shadows.dart';
> ```

- [ ] **Step 3: 用户气泡套 token**

在 `UserMessageBubble.build`(约 253-261 行)把:

```dart
              decoration: BoxDecoration(
                color: AppColors.userBubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
```

改为:

```dart
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.bubble),
                  topRight: Radius.circular(AppRadius.bubbleTail),
                  bottomLeft: Radius.circular(AppRadius.bubble),
                  bottomRight: Radius.circular(AppRadius.bubble),
                ),
                boxShadow: AppShadows.primary,
              ),
```

- [ ] **Step 4: 编译 + 真机验证**

Run: `flutter analyze lib/presentation/widgets/chat/message_bubble.dart`
Expected: No issues。

Run: `flutter run`
Expected: AI 气泡白底细边 + 暖投影;用户气泡 sage + 柔投影;入场为静润淡入上浮。

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/chat/message_bubble.dart
git commit -m "feat(chat): 消息气泡套用奶油暖调 token + 统一入场曲线"
```

---

## Task 9: ChatInputField 改造

**Files:**
- Modify: `health_xiaohe/lib/presentation/widgets/chat/chat_input_field.dart`

- [ ] **Step 1: 加 import + 换图标/配色**

文件顶部加:

```dart
import 'package:lucide_icons/lucide_icons.dart';
import 'package:health_xiaohe/core/constants/app_radius.dart';
import 'package:health_xiaohe/core/constants/app_shadows.dart';
```

- [ ] **Step 2: 输入栏容器套 token**

把输入栏外层 `Container`(约 121-126 行)的 decoration:

```dart
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
```

改为:

```dart
          decoration: const BoxDecoration(
            color: AppColors.bgBase,
            border: Border(top: BorderSide(color: AppColors.borderSoft)),
          ),
```

- [ ] **Step 3: 输入框药丸 + 发送/语音/加号换 lucide**

(a) 文字输入容器(约 151-155 行)`color: AppColors.inputBg` → `color: AppColors.bgCard`,并把外层包一层柔投影:把该 `Container` 的 decoration 改为:

```dart
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppRadius.chip + 4),
                      boxShadow: AppShadows.soft,
                    ),
```

(b) 加号按钮图标(约 144 行)`Icons.add` → `LucideIcons.plus`,边框色 `AppColors.divider` → `AppColors.border`。

(c) 录音键(约 174-177 行)`Icons.mic`/`Icons.stop` → `LucideIcons.mic`/`LucideIcons.square`。

(d) 发送按钮(约 190-194 行)装饰加投影、图标换 lucide:

```dart
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.primary,
                    ),
                    child: const Icon(LucideIcons.arrowUp, color: Colors.white, size: 18),
                  ),
```

(e) 功能面板项图标(`_buildPanel`,约 215-233 行)`Icons.image`/`Icons.call`/`Icons.favorite` → `LucideIcons.image`/`LucideIcons.phone`/`LucideIcons.heart`;颜色统一改为 `AppColors.primary`(去掉杂色,符合简约)。

- [ ] **Step 4: 编译 + 真机验证**

Run: `flutter analyze lib/presentation/widgets/chat/chat_input_field.dart`
Expected: No issues(图标名报错按相近名替换)。

Run: `flutter run`
Expected: 输入栏燕麦底、输入框白药丸带柔投影、发送键 sage 实心带投影、图标为 lucide 线性。

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/chat/chat_input_field.dart
git commit -m "feat(chat): 输入栏套 token + lucide 图标"
```

---

## Task 10: ChatHomePage 顶栏 + 问候区 + chip

**Files:**
- Modify: `health_xiaohe/lib/presentation/pages/chat/chat_home_page.dart`

- [ ] **Step 1: 加 import**

文件顶部加:

```dart
import 'package:lucide_icons/lucide_icons.dart';
import 'package:health_xiaohe/core/animations/entrance.dart';
import 'package:health_xiaohe/core/constants/app_radius.dart';
import 'package:health_xiaohe/core/constants/app_typography.dart';
```

- [ ] **Step 2: 顶栏 logo 圆角 + 图标换 lucide**

AppBar 的 logo 容器(约 84-92 行)`borderRadius: BorderRadius.circular(12)` → `BorderRadius.circular(AppRadius.logo)`;新建对话按钮(约 114-115 行)`Icons.add_comment` → `LucideIcons.plus`。AppBar `backgroundColor: Colors.white` → `AppColors.bgBase`(与 body 一致,去割裂感)。

- [ ] **Step 3: 重做 welcome 卡为宋体问候区**

把 `_buildWelcomeCard()` 整个方法(约 418-512 行)替换为:

```dart
  String _greetingByHour() {
    final h = DateTime.now().hour;
    if (h < 6) return '夜深了';
    if (h < 11) return '早安,我是小云';
    if (h < 14) return '午安,我是小云';
    if (h < 18) return '下午好,我是小云';
    return '晚上好,我是小云';
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Entrance(
            index: 0,
            child: Text('HEALTH XIAOHE', style: AppTypography.overline),
          ),
          const SizedBox(height: 6),
          Entrance(
            index: 1,
            child: Text(_greetingByHour(), style: AppTypography.displaySerif),
          ),
          const SizedBox(height: 4),
          Entrance(
            index: 2,
            child: Text('今天想聊些什么?我都在。',
                style: AppTypography.caption.copyWith(fontSize: 13)),
          ),
          const SizedBox(height: 16),
          // quick tips
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (prev, cur) =>
                prev.welcomeSuggestions != cur.welcomeSuggestions,
            builder: (context, state) {
              final tips = state.welcomeSuggestions.isNotEmpty
                  ? state.welcomeSuggestions
                  : const ['失眠怎么办', '血压正常值', '春季养生'];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < tips.length; i++)
                    Entrance(index: 3 + i, child: _buildQuickTip(tips[i])),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 4: quick tip / 追问 chip 套燕麦底**

把 `_buildQuickTip`(约 514-534 行)的容器装饰改为燕麦底无描边 + 文字 token:

```dart
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          text,
          style: AppTypography.caption.copyWith(color: AppColors.primaryDark),
        ),
      ),
```

同样把"追问建议"那段(约 200-208 行)的 chip 装饰:

```dart
                        decoration: BoxDecoration(
                          color: AppColors.aiBubbleBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.primaryDark)),
```

改为:

```dart
                        decoration: BoxDecoration(
                          color: AppColors.bgSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(s, style: AppTypography.caption.copyWith(color: AppColors.primaryDark)),
```

- [ ] **Step 5: 编译 + 真机视觉验证(对齐标杆稿)**

Run: `flutter analyze lib/presentation/pages/chat/chat_home_page.dart`
Expected: No issues。

Run: `flutter run`
Expected: 聊天主页 = 燕麦底 + 宋体问候(按时段)+ overline 小标签 + 燕麦底 chip,进入时问候区与标签依次淡入上浮;整体对齐标杆稿气质。

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/pages/chat/chat_home_page.dart
git commit -m "feat(chat): 聊天主页宋体问候区 + Entrance stagger + 燕麦 chip"
```

---

## 完成标准

- 全部 `flutter analyze` 无新增 error;`flutter test` 通过(colors、entrance)。
- 真机:聊天主页对齐标杆稿(燕麦底、宋体问候、哑光 sage 气泡、自定义导航、克制留白)。
- 页面跳转/tab 切换为静润淡入上浮;问候区 stagger 入场;无卡顿(延续上一轮主线程优化)。
- 未改造页面(画像/历史/我的/登录/通话)正常编译、自动呈现新配色、无错位。
- 字体:中文宋体标题、Fraunces 数字正确显示;APK 体积增量 1~3MB。

## 后续(不在本计划)

画像页、历史页、个人中心、登录页、通话页逐页套用本套系统;深色模式;插画/吉祥物。各自独立计划。
