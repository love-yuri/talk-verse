/*
 * @Author: love-yuri yuri2078170658@gmail.com
 * @Date: 2026-05-07 15:17:18
 * @LastEditTime: 2026-05-07 15:25:42
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

  AnthropicProvider(this.settings);

  @override
  Future<String> sendMessage(
    List<Message> messages, {
    String? systemPrompt,
  }) async {
    final uri = Uri.parse('${settings.baseUrl}/v1/messages');

    final request = AnthropicRequest(
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
    );

    final response = await http.post(
      uri,
      headers: {
        'x-api-key': settings.apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('API 请求失败: ${response.statusCode} ${response.body}');
    }

    final data = AnthropicResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    return data.text;
  }
}
