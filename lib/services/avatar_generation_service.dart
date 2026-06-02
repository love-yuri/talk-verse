import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'character_import_service.dart';
import 'settings_service.dart';

typedef AvatarGenerationProgress = void Function(String message);

class AvatarGenerationCancelled implements Exception {
  const AvatarGenerationCancelled();

  @override
  String toString() => '头像生成已取消';
}

class AvatarGenerationCancelToken {
  bool _cancelled = false;
  final List<VoidCallback> _callbacks = [];

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final callback in List<VoidCallback>.from(_callbacks)) {
      callback();
    }
    _callbacks.clear();
  }

  void throwIfCancelled() {
    if (_cancelled) throw const AvatarGenerationCancelled();
  }

  void onCancel(VoidCallback callback) {
    if (_cancelled) {
      callback();
      return;
    }
    _callbacks.add(callback);
  }

  void removeOnCancel(VoidCallback callback) {
    _callbacks.remove(callback);
  }
}

typedef VoidCallback = void Function();

/// 使用 OpenAI Images API 生成角色头像。
class AvatarGenerationService {
  final SettingsService settingsService;

  AvatarGenerationService({SettingsService? settingsService})
    : settingsService = settingsService ?? SettingsService();

  Future<String> generateAvatar({
    required String prompt,
    required String characterName,
    AvatarGenerationProgress? onProgress,
    AvatarGenerationCancelToken? cancelToken,
  }) async {
    onProgress?.call('正在读取头像生成配置...');
    cancelToken?.throwIfCancelled();
    final settings = await settingsService.load();
    final config = settings.imageApiConfig;
    if (!config.isConfigured) {
      throw Exception('请先在设置中配置头像生成 API Key');
    }

    final configuredOutputFormat = config.outputFormat.trim().toLowerCase();
    final outputFormat = configuredOutputFormat.isEmpty
        ? 'png'
        : configuredOutputFormat == 'jpg'
        ? 'jpeg'
        : configuredOutputFormat;
    final body = <String, Object>{
      'model': config.model.trim().isEmpty
          ? 'gpt-image-2'
          : config.model.trim(),
      'prompt': prompt.trim(),
      'n': 1,
      'size': config.size.trim().isEmpty ? '1024x1024' : config.size.trim(),
      'output_format': outputFormat,
    };
    final quality = config.quality.trim().toLowerCase();
    if (quality.isNotEmpty && quality != 'auto') {
      body['quality'] = quality;
    }

    final endpoint = _imageEndpoint(config.baseUrl);
    onProgress?.call('正在请求 ${body['model']} 生成头像...\nPOST $endpoint');
    final _HttpJsonResponse response;
    try {
      response = await _postJson(
        endpoint,
        apiKey: config.apiKey,
        body: body,
        cancelToken: cancelToken,
      );
    } catch (e) {
      if (e is AvatarGenerationCancelled) rethrow;
      throw Exception('请求头像生成接口失败：POST $endpoint\n$e');
    }

    cancelToken?.throwIfCancelled();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        '头像生成失败 (${response.statusCode})：POST $endpoint\n${_errorMessage(response.body)}',
      );
    }

    onProgress?.call('头像已生成，正在解析图片数据...');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final bytes = await _extractImageBytes(
      data,
      endpoint,
      onProgress,
      cancelToken,
    );
    cancelToken?.throwIfCancelled();
    onProgress?.call('正在保存头像到本地...');
    return CharacterImportService.saveAvatarImage(
      bytes,
      characterName.trim().isEmpty ? 'avatar' : characterName.trim(),
      extension: outputFormat == 'jpeg' ? 'jpg' : outputFormat,
    );
  }

  Future<Uint8List> _extractImageBytes(
    Map<String, dynamic> decoded,
    String generationEndpoint,
    AvatarGenerationProgress? onProgress,
    AvatarGenerationCancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    final items = decoded['data'] as List<dynamic>?;
    if (items == null || items.isEmpty) {
      throw Exception('头像生成响应中没有图片数据');
    }

    final item = items.first as Map<String, dynamic>;
    final b64 = item['b64_json'] as String?;
    if (b64 != null && b64.isNotEmpty) {
      onProgress?.call('正在解码头像图片...');
      cancelToken?.throwIfCancelled();
      return base64Decode(b64);
    }

    final url = item['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('头像生成响应中没有可用图片');
    }

    final imageUri = Uri.parse(url);
    final generationUri = Uri.parse(generationEndpoint);
    if (_sameEndpoint(imageUri, generationUri)) {
      throw Exception(
        '头像生成接口返回的图片 URL 不是图片文件，而是生成接口本身：\n$url\n'
        '这通常是中转服务不支持 Images API 的 url 返回，或返回格式异常。'
        '请尝试换用支持 /v1/images/generations 的地址，或让服务端返回 b64_json 图片数据。',
      );
    }

    onProgress?.call('正在下载生成的头像...\nGET $url');
    final _HttpBytesResponse response;
    try {
      response = await _getBytes(imageUri, cancelToken: cancelToken);
    } catch (e) {
      if (e is AvatarGenerationCancelled) rethrow;
      throw Exception('下载生成头像失败：GET $url\n$e');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('下载生成头像失败 (${response.statusCode})：GET $url');
    }
    return response.bodyBytes;
  }

  Future<_HttpJsonResponse> _postJson(
    String endpoint, {
    required String apiKey,
    required Map<String, Object> body,
    AvatarGenerationCancelToken? cancelToken,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = Duration.zero
      ..userAgent = 'OpenAI/Python compatible TalkVerse/1.1';

    void cancelClient() => client.close(force: true);
    cancelToken?.onCancel(cancelClient);

    try {
      cancelToken?.throwIfCancelled();
      final request = await client
          .postUrl(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 30));
      cancelToken?.throwIfCancelled();
      request.persistentConnection = false;
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey')
        ..set(HttpHeaders.acceptHeader, 'application/json')
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set(HttpHeaders.connectionHeader, 'close');

      final bytes = utf8.encode(jsonEncode(body));
      request.contentLength = bytes.length;
      request.add(bytes);
      cancelToken?.throwIfCancelled();

      final response = await request.close().timeout(
        const Duration(seconds: 120),
        onTimeout: () => throw Exception('头像生成超时，请稍后重试'),
      );
      cancelToken?.throwIfCancelled();
      final responseBody = await response.transform(utf8.decoder).join();
      cancelToken?.throwIfCancelled();
      return _HttpJsonResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } on AvatarGenerationCancelled {
      rethrow;
    } on HttpException {
      if (cancelToken?.isCancelled == true) {
        throw const AvatarGenerationCancelled();
      }
      rethrow;
    } on SocketException {
      if (cancelToken?.isCancelled == true) {
        throw const AvatarGenerationCancelled();
      }
      rethrow;
    } finally {
      cancelToken?.removeOnCancel(cancelClient);
      client.close(force: true);
    }
  }

  Future<_HttpBytesResponse> _getBytes(
    Uri uri, {
    AvatarGenerationCancelToken? cancelToken,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = Duration.zero
      ..userAgent = 'OpenAI/Python compatible TalkVerse/1.1';

    void cancelClient() => client.close(force: true);
    cancelToken?.onCancel(cancelClient);

    try {
      cancelToken?.throwIfCancelled();
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 30));
      cancelToken?.throwIfCancelled();
      request.persistentConnection = false;
      request.headers
        ..set(HttpHeaders.acceptHeader, 'image/*,*/*')
        ..set(HttpHeaders.connectionHeader, 'close');

      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      cancelToken?.throwIfCancelled();
      final builder = await response.fold<BytesBuilder>(
        BytesBuilder(copy: false),
        (builder, chunk) => builder..add(chunk),
      );
      cancelToken?.throwIfCancelled();
      return _HttpBytesResponse(
        statusCode: response.statusCode,
        bodyBytes: builder.takeBytes(),
      );
    } on AvatarGenerationCancelled {
      rethrow;
    } on HttpException {
      if (cancelToken?.isCancelled == true) {
        throw const AvatarGenerationCancelled();
      }
      rethrow;
    } on SocketException {
      if (cancelToken?.isCancelled == true) {
        throw const AvatarGenerationCancelled();
      }
      rethrow;
    } finally {
      cancelToken?.removeOnCancel(cancelClient);
      client.close(force: true);
    }
  }

  bool _sameEndpoint(Uri left, Uri right) {
    return left.scheme == right.scheme &&
        left.host == right.host &&
        left.port == right.port &&
        _trimSlash(left.path) == _trimSlash(right.path);
  }

  String _trimSlash(String path) {
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  String _errorMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'] as String?;
        if (message != null && message.trim().isNotEmpty) return message;
      }
      final message = decoded['message'] as String?;
      if (message != null && message.trim().isNotEmpty) return message;
    } catch (_) {
      // Fall through to raw body.
    }
    return body.trim().isEmpty ? '接口未返回错误详情' : body;
  }

  String _imageEndpoint(String baseUrl) {
    final base = baseUrl.trim().isEmpty
        ? 'https://api.openai.com'
        : baseUrl.trim();
    final normalized = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    if (normalized.endsWith('/images/generations')) return normalized;
    if (normalized.endsWith('/v1')) return '$normalized/images/generations';
    return '$normalized/v1/images/generations';
  }
}

class _HttpJsonResponse {
  final int statusCode;
  final String body;

  const _HttpJsonResponse({required this.statusCode, required this.body});
}

class _HttpBytesResponse {
  final int statusCode;
  final Uint8List bodyBytes;

  const _HttpBytesResponse({required this.statusCode, required this.bodyBytes});
}
