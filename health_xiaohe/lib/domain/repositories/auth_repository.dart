// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:health_xiaohe/data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String phone, String password);
  Future<AuthResult> register(String phone, String password, {String? nickname});
  Future<AuthResult> getCurrentUser();
  Future<void> logout();
  bool get isLoggedIn;
  String? get token;
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String? error;

  AuthResult.success(this.user)
      : success = true,
        error = null;

  AuthResult.failure(this.error)
      : success = false,
        user = null;
}
