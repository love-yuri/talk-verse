import '../models/message.dart';

/// AI 流式事件
sealed class AiEvent {}

/// 文本片段
class AiTextEvent extends AiEvent {
  final String text;
  AiTextEvent(this.text);
}

/// 单次请求的 Token 用量快照
class TokenUsage {
  final int inputTokens;
  final int cacheReadTokens;
  final int cacheCreateTokens;
  final int outputTokens;

  const TokenUsage({
    this.inputTokens = 0,
    this.cacheReadTokens = 0,
    this.cacheCreateTokens = 0,
    this.outputTokens = 0,
  });

  int get totalTokens => inputTokens + outputTokens;
}

/// AI 服务抽象接口
/// 所有 AI 服务商都需要实现此接口
abstract class AiProvider {
  /// 发送消息并获取 AI 回复
  ///
  /// [messages] 对话历史消息列表
  /// [systemPrompt] 系统提示词（可选）
  Future<String> sendMessage(List<Message> messages, {String? systemPrompt});

  /// 流式发送消息，逐段返回 AI 文本事件
  Stream<AiEvent> sendMessageStream(List<Message> messages, {String? systemPrompt});

  /// 最近一次请求的 token 用量。流式完成后由子类填充。
  TokenUsage? get lastUsage;

  /// 当前使用的模型名称
  String get model;

  /// 取消当前正在进行的请求
  void cancel();
}
