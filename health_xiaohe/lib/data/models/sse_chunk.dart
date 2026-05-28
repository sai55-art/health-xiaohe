// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
class SseChunk {
  final String? content;
  final String? conversationId;
  final List<String>? suggestions;

  const SseChunk({this.content, this.conversationId, this.suggestions});

  bool get hasContent => content != null && content!.isNotEmpty;
  bool get hasConversationId => conversationId != null && conversationId!.isNotEmpty;
  bool get hasSuggestions => suggestions != null && suggestions!.isNotEmpty;
}
