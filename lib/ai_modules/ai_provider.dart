import '../models/message.dart';

/// AI 服务抽象接口
/// 所有 AI 服务商都需要实现此接口
abstract class AiProvider {
  /// 发送消息并获取 AI 回复
  ///
  /// [messages] 对话历史消息列表
  /// [systemPrompt] 系统提示词（可选）
  Future<String> sendMessage(List<Message> messages, {String? systemPrompt});
}
