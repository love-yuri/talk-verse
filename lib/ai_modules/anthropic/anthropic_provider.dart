/*
 * @Author: love-yuri yuri2078170658@gmail.com
 * @Date: 2026-05-07 15:17:18
 * @LastEditTime: 2026-05-08 15:23:52
 * @Description:
 */
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ai_settings.dart';
import '../../models/message.dart';
import '../ai_provider.dart';
import 'anthropic_models.dart';

/// Anthropic API 实现
class AnthropicProvider implements AiProvider {
  final AiSettings settings;
  http.Client? _activeClient;
  TokenUsage? _lastUsage;

  AnthropicProvider(this.settings);

  @override
  TokenUsage? get lastUsage => _lastUsage;

  @override
  String get model => settings.model;

  @override
  void cancel() {
    _activeClient?.close();
    _activeClient = null;
  }

  /// 构建请求头
  Map<String, String> get _headers => {
    'x-api-key': settings.apiKey,
    'anthropic-version': '2023-06-01',
    'content-type': 'application/json',
  };

  /// 构建请求体
  Map<String, dynamic> _buildBody(
    List<Message> messages, {
    String? systemPrompt,
    bool stream = false,
  }) {
    return AnthropicRequest(
      model: settings.model,
      maxTokens: settings.reasoningEnabled ? 8192 : 1024,
      thinkingEnabled: settings.reasoningEnabled,
      thinkingBudgetTokens: settings.reasoningBudgetTokens,
      system: systemPrompt,
      messages: messages
          .map(
            (m) => AnthropicMessage(
              role: m.type == MessageType.user ? 'user' : 'assistant',
              content: [AnthropicContent(type: 'text', text: m.content)],
            ),
          )
          .toList(),
    ).toJson()..['stream'] = stream;
  }

  @override
  Future<String> sendMessage(
    List<Message> messages, {
    String? systemPrompt,
  }) async {
    final uri = Uri.parse('${settings.baseUrl}/v1/messages');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(_buildBody(messages, systemPrompt: systemPrompt)),
    );

    if (response.statusCode != 200) {
      throw Exception('API 请求失败: ${response.statusCode} ${response.body}');
    }

    final data = AnthropicResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    return data.text;
  }

  @override
  Stream<String> sendMessageStream(
    List<Message> messages, {
    String? systemPrompt,
  }) async* {
    final uri = Uri.parse('${settings.baseUrl}/v1/messages');
    final request = http.Request('POST', uri);
    request.headers.addAll(_headers);
    request.body = jsonEncode(
      _buildBody(messages, systemPrompt: systemPrompt, stream: true),
    );

    final client = http.Client();
    _activeClient = client;
    try {
      final streamedResponse = await client
          .send(request)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('连接超时 (30s)'),
          );
      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        throw Exception('API 请求失败: ${streamedResponse.statusCode} $body');
      }

      // 解析 SSE 流，每 30 秒无数据则超时
      String buffer = '';
      int inputTokens = 0;
      int cacheRead = 0;
      int cacheCreate = 0;
      int outputTokens = 0;
      final stream = streamedResponse.stream
          .transform(utf8.decoder)
          .timeout(const Duration(seconds: 30));
      await for (final chunk in stream) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith('event: ')) continue;
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final type = json['type'] as String?;

            if (type == 'message_start') {
              final usage = json['message']?['usage'] as Map<String, dynamic>?;
              if (usage != null) {
                inputTokens = (usage['input_tokens'] as num?)?.toInt() ?? 0;
                cacheRead = (usage['cache_read_input_tokens'] as num?)?.toInt() ?? 0;
                cacheCreate = (usage['cache_creation_input_tokens'] as num?)?.toInt() ?? 0;
              }
            } else if (type == 'message_delta') {
              final usage = json['usage'] as Map<String, dynamic>?;
              if (usage != null) {
                outputTokens = (usage['output_tokens'] as num?)?.toInt() ?? 0;
              }
              _lastUsage = TokenUsage(
                inputTokens: inputTokens,
                cacheReadTokens: cacheRead,
                cacheCreateTokens: cacheCreate,
                outputTokens: outputTokens,
              );
            } else if (type == 'content_block_delta') {
              final delta = json['delta'] as Map<String, dynamic>?;
              final deltaType = delta?['type'] as String?;
              if (deltaType == 'text_delta') {
                yield delta!['text'] as String;
              }
            } else if (type == 'error') {
              final err = json['error'] as Map<String, dynamic>?;
              throw Exception('API 错误: ${err?['message'] ?? data}');
            }
          } catch (_) {}
        }
      }
    } finally {
      _activeClient = null;
      client.close();
    }
  }
}
