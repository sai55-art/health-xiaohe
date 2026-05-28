// ============================================================
// AI 生成：本文件由 AI（Claude / Trae）辅助生成
// 人工修改：经开发者 review、测试反馈与需求确认后迭代调整
// ============================================================
import 'package:equatable/equatable.dart';

abstract class ChatHistoryEvent extends Equatable {
  const ChatHistoryEvent();

  @override
  List<Object?> get props => [];
}

class ChatHistoryLoadConversations extends ChatHistoryEvent {}

class ChatHistoryLoadConversationDetail extends ChatHistoryEvent {
  final String conversationId;

  const ChatHistoryLoadConversationDetail(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ChatHistoryDeleteConversation extends ChatHistoryEvent {
  final String conversationId;

  const ChatHistoryDeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}
