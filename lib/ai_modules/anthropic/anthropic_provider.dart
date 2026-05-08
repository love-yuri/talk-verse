/*
 * @Author: love-yuri yuri2078170658@gmail.com
 * @Date: 2026-05-07 15:17:18
 * @LastEditTime: 2026-05-07 15:25:42
 * @Description:
 */
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/ai_settings.dart';
import '../../models/message.dart';
import '../ai_provider.dart';
import 'anthropic_models.dart';

/// Anthropic API 实现
class AnthropicProvider implements AiProvider {
  final AiSettings settings;

  AnthropicProvider(this.settings);

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
      maxTokens: 1024,
      system: systemPrompt,
      messages: messages
          .map(
            (m) => AnthropicMessage(
              role: m.type == MessageType.user ? 'user' : 'assistant',
              content: [AnthropicContent(type: 'text', text: m.content)],
            ),
          )
          .toList(),
    ).toJson()
      ..['stream'] = stream;
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

    final reqTime = DateTime.now();
    debugPrint('[API] 请求已发送 → $uri');
    debugPrint('[API] 模型: ${settings.model}, 消息数: ${messages.length}');

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('连接超时 (30s)'),
      );
      final ttfb = DateTime.now().difference(reqTime);
      debugPrint('[API] 连接已建立, TTFB: ${ttfb.inMilliseconds}ms, 状态码: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        throw Exception('API 请求失败: ${streamedResponse.statusCode} $body');
      }

      // 解析 SSE 流
      int tokenCount = 0;
      int thinkingCount = 0;
      String currentBlock = '';
      DateTime? firstTokenTime;
      DateTime? thinkingStartTime;
      String buffer = '';
      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith('event: ')) continue;
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') {
            final total = DateTime.now().difference(reqTime);
            debugPrint('[API] 流完成: ${tokenCount}个text token, ${thinkingCount}个thinking token, 总耗时: ${total.inMilliseconds}ms');
            return;
          }

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final type = json['type'] as String?;

            if (type == 'content_block_start') {
              final block = json['content_block'] as Map<String, dynamic>?;
              currentBlock = block?['type'] as String? ?? '';
              if (currentBlock == 'thinking') {
                thinkingStartTime = DateTime.now();
                debugPrint('[API] thinking block 开始');
              }
            } else if (type == 'content_block_stop') {
              if (currentBlock == 'thinking' && thinkingStartTime != null) {
                final elapsed = DateTime.now().difference(thinkingStartTime);
                debugPrint('[API] thinking block 结束, 耗时: ${elapsed.inMilliseconds}ms, ${thinkingCount}个token');
              }
              currentBlock = '';
            } else if (type == 'content_block_delta') {
              final delta = json['delta'] as Map<String, dynamic>?;
              final deltaType = delta?['type'] as String?;

              if (deltaType == 'thinking_delta') {
                thinkingCount++;
              } else if (deltaType == 'text_delta') {
                if (firstTokenTime == null) {
                  firstTokenTime = DateTime.now();
                  debugPrint('[API] 首个text token, TTFT: ${firstTokenTime!.difference(reqTime).inMilliseconds}ms');
                }
                tokenCount++;
                yield delta!['text'] as String;
              }
            } else if (type == 'error') {
              final err = json['error'] as Map<String, dynamic>?;
              throw Exception('API 错误: ${err?['message'] ?? data}');
            }
          } on Exception catch (e) {
            debugPrint('[API] 解析异常: $e');
            rethrow;
          } catch (_) {}
        }
      }
    } finally {
      client.close();
      debugPrint('[API] HTTP Client 已关闭');
    }
  }
}
