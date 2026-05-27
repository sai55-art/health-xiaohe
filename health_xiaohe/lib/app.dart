import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_xiaohe/core/theme/app_theme.dart';
import 'package:health_xiaohe/core/theme/theme_controller.dart';
import 'package:health_xiaohe/injection.dart';
import 'package:health_xiaohe/presentation/blocs/auth/auth_bloc.dart';
import 'package:health_xiaohe/presentation/blocs/auth/auth_event.dart';
import 'package:health_xiaohe/presentation/blocs/chat/chat_bloc.dart';
import 'package:health_xiaohe/presentation/blocs/chat_history/chat_history_bloc.dart';
import 'package:health_xiaohe/presentation/blocs/health/health_bloc.dart';
import 'package:health_xiaohe/presentation/blocs/voice/voice_bloc.dart';
import 'package:health_xiaohe/presentation/router/app_router.dart';

class HealthXiaoheApp extends StatelessWidget {
  const HealthXiaoheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => getIt<ChatBloc>(),
        ),
        BlocProvider<ChatHistoryBloc>(
          create: (_) => getIt<ChatHistoryBloc>(),
        ),
        BlocProvider<HealthBloc>(
          create: (_) => getIt<HealthBloc>(),
        ),
        BlocProvider<VoiceBloc>(
          create: (_) => getIt<VoiceBloc>(),
        ),
      ],
      child: ValueListenableBuilder<bool>(
        valueListenable: ThemeController.isDark,
        builder: (context, isDark, __) {
          return MaterialApp.router(
            title: '健康小云',
            theme: AppTheme.theme,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            // 切换主题时，用 KeyedSubtree(isDark) 重建 Router 输出的整个 Navigator
            // 子树 → 栈内所有页面（含被设置页盖住的下层页）重新 build 读新 AppColors
            // 立即变色。导航栈由 Navigator 的 GlobalKey 保留(reparent 而非并存)，
            // 不丢栈、不会 Duplicate GlobalKey；不给 MaterialApp 本身换 key，
            // 故不触碰 GoRouter 的 RouterDelegate。
            builder: (context, child) {
              return KeyedSubtree(
                key: ValueKey<bool>(isDark),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
