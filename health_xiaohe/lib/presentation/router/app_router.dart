import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_xiaohe/presentation/blocs/auth/auth_bloc.dart';
import 'package:health_xiaohe/presentation/blocs/auth/auth_state.dart';
import 'package:health_xiaohe/presentation/pages/auth/login_page.dart';
import 'package:health_xiaohe/presentation/pages/chat/call_page.dart';
import 'package:health_xiaohe/presentation/pages/chat/chat_home_page.dart';
import 'package:health_xiaohe/presentation/pages/history/chat_history_page.dart';
import 'package:health_xiaohe/presentation/pages/history/conversation_detail_page.dart';
import 'package:health_xiaohe/presentation/pages/profile/personal_center_page.dart';
import 'package:health_xiaohe/presentation/pages/profile/user_profile_page.dart';
import 'package:health_xiaohe/presentation/pages/settings/settings_page.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';
import 'package:health_xiaohe/core/animations/page_transitions.dart';
import 'package:health_xiaohe/presentation/widgets/common/app_bottom_nav.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String chatHome = '/chat';
  static String chatWithConversation(String id) => '/chat?conversationId=$id';
  static const String aiImpression = '/ai-impression';
  static const String chatHistory = '/chat-history';
  static const String personalCenter = '/profile';
  static const String call = '/call';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (context, state) =>
            fadeUpPage(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: login,
        pageBuilder: (context, state) =>
            fadeUpPage(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: call,
        pageBuilder: (context, state) =>
            fadeUpPage(state: state, child: const CallPage()),
      ),
      GoRoute(
        path: settings,
        pageBuilder: (context, state) =>
            fadeUpPage(state: state, child: const SettingsPage()),
      ),
      GoRoute(
        path: '/chat-history/:conversationId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['conversationId']!;
          return fadeUpPage(
              state: state, child: ConversationDetailPage(conversationId: id));
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: chatHome,
            builder: (context, state) => const ChatHomePage(),
          ),
          GoRoute(
            path: aiImpression,
            builder: (context, state) => const UserProfilePage(),
          ),
          GoRoute(
            path: chatHistory,
            builder: (context, state) => const ChatHistoryPage(),
          ),
          GoRoute(
            path: personalCenter,
            builder: (context, state) => const PersonalCenterPage(),
          ),
        ],
      ),
    ],
  );
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.go(AppRouter.chatHome);
      } else {
        context.go(AppRouter.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F8F7),
              Color(0xFFD4F4F1),
              Color(0xFFC5EDE9),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 60,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🌿', style: TextStyle(fontSize: 60)),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        '健康小云',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        '您的 AI 健康管家',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 深色模式的全局变色由 app.dart 中 MaterialApp.builder 的 KeyedSubtree(isDark)
    // 统一处理（重建整个 Navigator 子树），这里无需再监听主题。
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // 注意: chatHistory('/chat-history') 必须在 chatHome('/chat') 之前判断,
    // 否则 '/chat-history'.startsWith('/chat') 会提前命中咨询 tab。
    if (location.startsWith(AppRouter.chatHistory)) return 2;
    if (location.startsWith(AppRouter.aiImpression)) return 1;
    if (location.startsWith(AppRouter.personalCenter)) return 3;
    if (location.startsWith(AppRouter.chatHome)) return 0;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRouter.chatHome);
        break;
      case 1:
        context.go(AppRouter.aiImpression);
        break;
      case 2:
        context.go(AppRouter.chatHistory);
        break;
      case 3:
        context.go(AppRouter.personalCenter);
        break;
    }
  }
}
