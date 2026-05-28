// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_xiaohe/core/constants/app_colors.dart';
import 'package:health_xiaohe/core/constants/app_radius.dart';
import 'package:health_xiaohe/core/constants/app_shadows.dart';
import 'package:health_xiaohe/core/constants/app_spacing.dart';
import 'package:health_xiaohe/core/constants/app_strings.dart';
import 'package:health_xiaohe/core/constants/app_typography.dart';
import 'package:health_xiaohe/core/animations/entrance.dart';
import 'package:health_xiaohe/presentation/blocs/auth/auth_bloc.dart';
import 'package:health_xiaohe/presentation/blocs/auth/auth_event.dart';
import 'package:health_xiaohe/presentation/blocs/auth/auth_state.dart';
import 'package:health_xiaohe/presentation/router/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.chatHome);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state is AuthRegistered) {
          // After registration, switch to login mode
          setState(() {
            _isLogin = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('注册成功，请登录'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.bgBase, AppColors.bgCard],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 72),
                  // 品牌锚点:克制的鼠尾草小方块,主视觉交给宋体大字
                  Entrance(
                    index: 0,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.logo),
                        boxShadow: AppShadows.primary,
                      ),
                      child: const Center(
                        child: Text('🌿', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Fraunces overline,与首页问候区呼应
                  Entrance(
                    index: 1,
                    child: Text('HEALTH XIAOHE', style: AppTypography.overline),
                  ),
                  const SizedBox(height: 6),
                  // 宋体大字品牌名 — 主视觉
                  Entrance(
                    index: 2,
                    child: Text(
                      AppStrings.appName,
                      style: AppTypography.displaySerif.copyWith(fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Entrance(
                    index: 3,
                    child: Text(
                      AppStrings.appSlogan,
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Phone input
                  Entrance(
                    index: 4,
                    child: _buildTextField(
                      controller: _phoneController,
                      hint: AppStrings.phoneHint,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(Icons.phone_outlined,
                          color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Password input
                  Entrance(
                    index: 5,
                    child: _buildTextField(
                      controller: _passwordController,
                      hint: AppStrings.passwordHint,
                      obscureText: _obscurePassword,
                      prefixIcon: Icon(Icons.lock_outlined,
                          color: AppColors.textTertiary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Submit button - 主色实底 + 暖投影
                  Entrance(
                    index: 5,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.input),
                            boxShadow: AppShadows.primary,
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.input),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isLogin
                                        ? AppStrings.login
                                        : AppStrings.register,
                                    style: AppTypography.titleSans.copyWith(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // 协议 + 切换登录/注册居中
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '登录即表示同意《用户协议》和《隐私政策》',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? AppStrings.noAccount
                                : AppStrings.hasAccount,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textPlaceholder),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  void _onSubmit() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码至少6位')),
      );
      return;
    }

    if (_isLogin) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(phone: phone, password: password),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(phone: phone, password: password),
          );
    }
  }
}
