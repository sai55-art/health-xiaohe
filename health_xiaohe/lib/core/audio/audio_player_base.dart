// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'dart:async';

abstract class AudioPlayerBase {
  Future<void> play(String base64Pcm);
  Future<void> setSpeaker(bool on) async {}
  void stop();
  void dispose();
}
